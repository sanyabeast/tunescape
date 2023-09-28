import 'package:flutter/material.dart';
import 'package:tunescape/core/playback.dart';

GlobalKey _statusStateKey = GlobalKey();

class PlaybackStatusWidget extends StatefulWidget {
  PlaybackStatusWidget({Key? key}) : super(key: _statusStateKey);

  @override
  _PlaybackStatusWidgetState createState() => _PlaybackStatusWidgetState();
}

class _PlaybackStatusWidgetState extends State<PlaybackStatusWidget> {
  PlaybackManager playbackManager = PlaybackManager.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(playbackManager.currentFileName),
              const Text('M4A, 44 kHz, 128 kbps, Stereo'),
            ],
          ),
        ),
      ],
    );
  }
}
