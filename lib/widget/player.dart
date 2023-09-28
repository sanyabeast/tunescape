import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunescape/core/playback.dart';
import 'package:tunescape/core/playlist.dart';
import 'package:tunescape/core/tools.dart';

const double leftSectionWidth = 300;
const double bottomSectionHeight = 150;

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({Key? key}) : super(key: key);
  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> with TickerProviderStateMixin {
  PlaybackManager playbackManager = PlaybackManager.instance;
  final AudioPlayer _player = AudioPlayer();

  late AnimationController _ticker;

  Future<void> _pickAndPlayAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null) {
      playbackManager.playFile(result.files.single.path!);
      setState(() {});
    }
  }

  Future<void> _loadPlaylist() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['m3u8'],
    );

    if (result != null) {
      var file = result.files.single.path!;
      List<String> playlist = await PlaylistManager.instance.loadPlaylist(file);
      playbackManager.replacePlaylist(playlist);

      setState(() {});
    } else {
      // User canceled the picker
    }
  }

  @override
  void initState() {
    _ticker = AnimationController(duration: const Duration(seconds: 1), vsync: this)
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _ticker.reset();
          _ticker.forward();
        }
      })
      ..addListener(() {
        setState(() {});
      });

    super.initState();
  }

  @override
  void dispose() {
    _player.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double playbackDuration = playbackManager.playbackDuration;
    double playbackPosition = playbackManager.playbackPosition;

    String titleText =
        playbackManager.isPlaying ? '${playbackManager.currentFileName}' : 'tunescape';

    return Scaffold(
        appBar: AppBar(
          title: Text(titleText),
          actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
        ),
        drawer: createDrawer(context),
        body: Column(
          children: [
            Expanded(
                child: Row(
              children: [
                Container(
                    width: leftSectionWidth,
                    color: const Color.fromARGB(255, 15, 15, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(playbackManager.currentFileName),
                              Text('M4A, 44 kHz, 128 kbps, Stereo'),
                            ],
                          ),
                        ),
                      ],
                    )),
                Expanded(
                    flex: 2,
                    child: Column(
                      children: [createPlaylistView(context)],
                    ))
              ],
            )),
            Container(
              height: bottomSectionHeight,
              color: const Color.fromARGB(255, 20, 20, 20),
              child: Row(children: [
                SizedBox(
                  width: leftSectionWidth,
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        createPlaybackControls(context),
                      ]),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      child: Column(
                        children: [
                          Text(
                              '${formatDuration(playbackPosition.toInt())} / ${formatDuration(playbackDuration.toInt())}'),
                          Slider(
                            min: 0,
                            max: 1,
                            value: playbackManager.progress,
                            onChanged: playbackManager.isEmpty
                                ? null
                                : (value) {
                                    playbackManager.progress = value;
                                  },
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              IconButton(
                                  icon: Icon(
                                      playbackManager.isMuted ? Icons.volume_off : Icons.volume_up),
                                  onPressed: playbackManager.isEmpty
                                      ? null
                                      : () {
                                          playbackManager.isMuted = !playbackManager.isMuted;
                                          setState(() {});
                                        }),
                              Slider(
                                min: 0,
                                max: 1,
                                value: playbackManager.volume,
                                onChanged: playbackManager.isEmpty
                                    ? null
                                    : (value) {
                                        playbackManager.volume = value;
                                      },
                              )
                            ],
                          )
                        ],
                      )),
                )
              ]),
            )
          ],
        ));
  }

  Drawer createDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  'tunescape',
                  style: TextStyle(fontSize: 32, color: Colors.red),
                ),
                Text(
                  "0.1.1a",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                )
              ])),
          ListTile(
            title: Text('Open audio file'),
            onTap: () {
              _pickAndPlayAudio();
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Open playlist'),
            onTap: () {
              _loadPlaylist();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget createPlaybackControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            icon: Icon(Icons.skip_previous),
            iconSize: 32,
            onPressed: playbackManager.isEmpty || playbackManager.isSingle
                ? null
                : () {
                    playbackManager.playPrevious();
                    setState(() {});
                  }),
        IconButton(
            icon: Icon(playbackManager.shuffle ? Icons.shuffle_on : Icons.shuffle),
            onPressed: playbackManager.isEmpty || playbackManager.isSingle
                ? null
                : () {
                    playbackManager.shuffle = !playbackManager.shuffle;
                    setState(() {});
                  }),
        IconButton(
            icon: Icon(
                playbackManager.isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline),
            iconSize: 48,
            onPressed: playbackManager.isEmpty
                ? null
                : () {
                    playbackManager.togglePlayback();
                    setState(() {});
                  }),
        IconButton(
            icon: getLoopModeIcon(playbackManager.loopMode),
            onPressed: playbackManager.isEmpty
                ? null
                : () {
                    playbackManager.nextLoopMode();
                    setState(() {});
                  }),
        IconButton(
            icon: const Icon(Icons.skip_next),
            iconSize: 32,
            onPressed: playbackManager.isEmpty || playbackManager.isSingle
                ? null
                : () {
                    playbackManager.playNext();
                    setState(() {});
                  }),
      ],
    );
  }

  Widget createPlaylistView(BuildContext context) {
    if (playbackManager.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('( ˘･з･) '),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: playbackManager.playlist.length,
        itemBuilder: (context, index) {
          return ListTile(
            tileColor: index == playbackManager.currentPlaylistItemIndex
                ? Colors.red[900]
                : null, // Highlight the selected item with a different color
            title: Text(getFileName(playbackManager.playlist[index])),
            subtitle: Text('M4A • 44 kHz, 129 kbps, Details...'),
            trailing: Text('1:30:00'),
            onTap: () => playbackManager.setPlaylistIndex(index),
          );
        },
      ),
    );
  }

  Icon getLoopModeIcon(LoopMode loopMode) {
    switch (loopMode) {
      case LoopMode.off:
        return const Icon(Icons.repeat);
      case LoopMode.one:
        return const Icon(Icons.repeat_one_on);
      case LoopMode.all:
        return const Icon(Icons.repeat_on);
    }
  }
}
