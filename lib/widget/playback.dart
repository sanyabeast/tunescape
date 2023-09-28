import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunescape/core/playback.dart';
import 'package:tunescape/core/state.dart';

import '../core/tools.dart';

GlobalKey _playbackStateKey = GlobalKey();

class PlaybackWidget extends StatefulWidget {
  PlaybackWidget({Key? key}) : super(key: _playbackStateKey);

  @override
  _PlaybackWidgetState createState() => _PlaybackWidgetState();
}

class _PlaybackWidgetState extends State<PlaybackWidget> {
  PlaybackManager playbackManager = PlaybackManager.instance;

  @override
  Widget build(BuildContext context) {
    double playbackDuration = playbackManager.playbackDuration;
    double playbackPosition = playbackManager.playbackPosition;

    return Row(children: [
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
                Container(
                  width: double.infinity,
                  height: 20,
                  child: playbackManager.isEmpty
                      ? Container()
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text('${formatDuration(playbackPosition.toInt())}'),
                            Text(' / ', style: TextStyle(color: Colors.grey)),
                            Text(
                              '${formatDuration(playbackDuration.toInt())}',
                              style: TextStyle(color: Colors.grey),
                            )
                          ],
                        ),
                ),
                SliderTheme(
                  data: SliderThemeData(
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8.0), // Adjust to your preference
                    trackHeight: 2.0, // Adjust to your preference
                    activeTrackColor: themeManager.colors.swatch,
                    inactiveTrackColor: Colors.grey[600],
                    thumbColor: themeManager.colors.accent,
                  ),
                  child: Slider(
                    min: 0,
                    max: 1,
                    value: playbackManager.progress,
                    onChanged: playbackManager.isEmpty
                        ? null
                        : (value) {
                            playbackManager.progress = value;
                          },
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                        icon: Icon(playbackManager.isMuted ? Icons.volume_off : Icons.volume_up),
                        onPressed: playbackManager.isEmpty
                            ? null
                            : () {
                                playbackManager.isMuted = !playbackManager.isMuted;
                                setState(() {});
                              }),
                    SliderTheme(
                      data: SliderThemeData(
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 5.0), // Adjust to your preference
                        trackHeight: 2.0, // Adjust to your preference
                        activeTrackColor: themeManager.colors.swatch,
                        inactiveTrackColor: Colors.grey[800],
                        thumbColor: themeManager.colors.accent,
                      ),
                      child: Slider(
                        min: 0,
                        max: 1,
                        value: playbackManager.volume,
                        onChanged: playbackManager.isEmpty
                            ? null
                            : (value) => playbackManager.volume = value,
                      ),
                    )
                  ],
                )
              ],
            )),
      )
    ]);
  }

  Widget createPlaybackControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            icon: Icon(Icons.skip_previous),
            iconSize: 24,
            onPressed: playbackManager.isEmpty || playbackManager.isSingle
                ? null
                : () {
                    playbackManager.playPrevious();
                    setState(() {});
                  }),
        IconButton(
            icon: Icon(playbackManager.shuffle ? Icons.shuffle_on : Icons.shuffle),
            iconSize: 24,
            onPressed: playbackManager.isEmpty || playbackManager.isSingle
                ? null
                : () {
                    playbackManager.shuffle = !playbackManager.shuffle;
                    setState(() {});
                  }),
        IconButton(
            icon: Icon(
                playbackManager.isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline),
            iconSize: 56,
            onPressed: playbackManager.isEmpty
                ? null
                : () {
                    playbackManager.togglePlayback();
                    setState(() {});
                  }),
        IconButton(
            icon: getLoopModeIcon(playbackManager.loopMode),
            iconSize: 24,
            onPressed: playbackManager.isEmpty
                ? null
                : () {
                    playbackManager.nextLoopMode();
                    setState(() {});
                  }),
        IconButton(
            icon: const Icon(Icons.skip_next),
            iconSize: 24,
            onPressed: playbackManager.isEmpty || playbackManager.isSingle
                ? null
                : () {
                    playbackManager.playNext();
                    setState(() {});
                  }),
      ],
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
