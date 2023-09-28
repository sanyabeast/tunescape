import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunescape/core/playback.dart';
import 'package:tunescape/core/playlist.dart';
import 'package:tunescape/core/state.dart';
import 'package:tunescape/widget/playback.dart';
import 'package:tunescape/widget/playlist.dart';
import 'package:tunescape/widget/status.dart';

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
        preferences.tick();
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
    String titleText = playbackManager.isPlaying ? playbackManager.currentFileName : 'tunescape';

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
                    child: PlaybackStatusWidget()),
                Expanded(
                    flex: 2,
                    child: Column(
                      children: [PlaylistWidget()],
                    ))
              ],
            )),
            Container(
              height: bottomSectionHeight,
              color: const Color.fromARGB(255, 20, 20, 20),
              child: PlaybackWidget(),
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
            title: const Text('Open audio file'),
            onTap: () {
              _pickAndPlayAudio();
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Open playlist'),
            onTap: () {
              _loadPlaylist();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
