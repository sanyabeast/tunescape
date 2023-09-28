import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunescape/core/playback.dart';
import 'package:tunescape/core/playlist.dart';
import 'package:tunescape/core/state.dart';
import 'package:tunescape/widget/playback.dart';
import 'package:tunescape/widget/playlist.dart';
import 'package:tunescape/widget/settings.dart';
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
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: supportedAudiofileExtensions);

    if (result != null) {
      playbackManager.playFile(result.files.single.path!);
      setState(() {});
    }
  }

  Future<void> _loadPlaylist() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: supportedPlaylistExtensions,
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

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Settings'),
          content: SettingsWidget(), // You can add more widgets here as per your requirements
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
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
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: Row(
            children: [
              Container(
                  width: leftSectionWidth,
                  color: Color.fromARGB(255, 10, 10, 10),
                  child: Scaffold(
                      appBar: AppBar(),
                      drawer: createDrawer(context),
                      body: PlaybackStatusWidget())),
              VerticalDivider(
                width: 2,
                color: Colors.grey[850],
              ),
              Expanded(
                  flex: 2,
                  child: Column(
                    children: [PlaylistWidget()],
                  ))
            ],
          )),
          Divider(
            height: 2,
            color: Colors.grey[850],
          ),
          Container(
            height: bottomSectionHeight,
            color: Colors.black,
            child: PlaybackWidget(),
          )
        ],
      ),
    );
  }

  Drawer createDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          createDrawerHeader(context),
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
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              _showSettingsDialog(context); // Open the settings dialog
            },
          ),
        ],
      ),
    );
  }

  DrawerHeader createDrawerHeader(BuildContext context) {
    return DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            'tunescape',
            style: TextStyle(fontSize: 32, color: accentColorNotifier.colors.accent),
          ),
          Text(
            "0.1.1a",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          )
        ]));
  }
}
