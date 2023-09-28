import 'package:flutter/material.dart';
import 'package:tunescape/core/playback.dart';
import 'package:tunescape/core/state.dart';

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
                ? themeManager.colors.swatch.withOpacity(0.33)
                : (index % 2 == 0
                    ? const Color.fromARGB(66, 40, 40, 40)
                    : null), // Highlight the selected item with a different color
            title: Text(getFileName(playbackManager.playlist[index])),
            subtitle: const Text(
              'M4A • 44 kHz, 129 kbps, Details...',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: const Text('1:30:00'),
            onTap: () => playbackManager.setPlaylistIndex(index),
          );
        },
      ),
    );
  }
}
