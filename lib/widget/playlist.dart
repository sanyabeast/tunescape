import 'package:flutter/material.dart';
import 'package:tunescape/core/playback.dart';

import '../core/tools.dart';

GlobalKey _playlistStateKey = GlobalKey();

class PlaylistWidget extends StatefulWidget {
  PlaylistWidget({Key? key}) : super(key: _playlistStateKey);

  @override
  _PlaylistWidgetState createState() => _PlaylistWidgetState();
}

class _PlaylistWidgetState extends State<PlaylistWidget> {
  PlaybackManager playbackManager = PlaybackManager.instance;

  @override
  Widget build(BuildContext context) {
    if (playbackManager.isEmpty) {
      return const Expanded(
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
                : (index % 2 == 0
                    ? Color.fromARGB(66, 72, 72, 72)
                    : null), // Highlight the selected item with a different color
            title: Text(getFileName(playbackManager.playlist[index])),
            subtitle: const Text(
              'M4A • 44 kHz, 129 kbps, Details...',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: Text('1:30:00'),
            onTap: () => playbackManager.setPlaylistIndex(index),
          );
        },
      ),
    );
  }
}
