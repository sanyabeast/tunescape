import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunescape/core/state.dart';
import 'package:tunescape/core/tools.dart';

class PlaybackManager {
  PlaybackManager() {
    volume = preferences.getOrDefault('volume', 0.5);
    shuffle = preferences.getOrDefault('shuffle', false);
  }

  final AudioPlayer _player = AudioPlayer();

  static final PlaybackManager _instance = PlaybackManager();
  static PlaybackManager get instance => _instance;

  double _volume = 0.5;
  double get volume => _volume;
  set volume(double value) {
    preferences.set('volume', value);
    _volume = clampDouble(value, 0, 1);
    _player.setVolume(_volume);
  }

  LoopMode loopMode = LoopMode.all;
  double volumeStep = 0.1;

  bool get isPlaying => _player.playing;

  bool _shuffle = false;
  bool get shuffle => _shuffle;
  set shuffle(bool value) {
    _shuffle = value;
    preferences.set('shuffle', value);
  }

  bool get isEmpty => playlist.isEmpty;
  bool get isSingle => playlist.length == 1;

  double get playbackDuration => _player.duration?.inSeconds?.toDouble() ?? 0.0;
  double get playbackPosition => _player.position?.inSeconds?.toDouble() ?? 0.0;

  bool get isMuted => _player.volume <= 0.0;
  set isMuted(bool value) => {_player.setVolume(value ? 0.0 : volume)};

  set progress(double progress) {
    seek(progress * playbackDuration);
  }

  double get progress {
    return playbackDuration > 0 ? playbackPosition / playbackDuration : 0.0;
  }

  String? currentFilePath = "";
  String get currentFileName => getFileName(currentFilePath!);

  List<String> playlist = [];

  int currentPlaylistItemIndex = 0;

  init() async {
    _player.processingStateStream.listen((event) {
      if (event == ProcessingState.completed) {
        _handleTrackCompleted();
      }
    });

    _player.sequenceStateStream.listen((event) {
      print("PlaybackManager: sequenceStateStream: $event");
    });

    // _player.durationStream.listen((event) {
    //   print("PlaybackManager: durationStream: $event");
    // });

    // _player.positionStream.listen((event) {
    //   print("PlaybackManager: positionStream: $event");
    // });

    _player.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        _handleTrackCompleted();
      }
    });

    _player.currentIndexStream.listen((event) {
      print("PlaybackManager: currentIndexStream: $event");
    });

    _player.loopModeStream.listen((event) {
      print("PlaybackManager: loopModeStream: $event");
    });

    _player.play();
    await _player.stop();
  }

  _handleTrackCompleted() {
    print("PlaybackManager: _handleTrackCompleted");
    switch (loopMode) {
      case LoopMode.off:
        if (currentPlaylistItemIndex < playlist.length - 1) {
          print("PlaybackManager: playNext");
          playNext();
        } else {
          print("PlaybackManager: none");
        }
        break;
      case LoopMode.one:
        print("PlaybackManager: replay");
        replay();
        break;
      case LoopMode.all:
        print("PlaybackManager: playNext");
        playNext();
        break;
    }
  }

  dispose() {
    print("PlaybackManager: dispose");
    _player.stop();
    _player.dispose();
  }

  playFile(String filePath, {bool addToPlaylist = true}) async {
    await _player.stop();

    print("PlaybackManager: prepare to play $filePath");

    currentFilePath = filePath;

    if (addToPlaylist) {
      playlist.add(filePath);
      currentPlaylistItemIndex = playlist.length - 1;
    }

    await _player.setFilePath(filePath);
    await _player.play();
    await _player.setVolume(volume);
  }

  replay() async {
    await playFile(playlist[currentPlaylistItemIndex], addToPlaylist: false);
  }

  setPlaylistIndex(int index) async {
    if (index < 0 || index >= playlist.length) {
      return;
    }

    if (currentPlaylistItemIndex == index) {
      await togglePlayback();
      return;
    }

    currentPlaylistItemIndex = index;
    await playFile(playlist[index], addToPlaylist: false);
  }

  playNext() async {
    if (playlist.length == 1) {
      await replay();
      return;
    }
    int newIndex = shuffle
        ? getRandomIntExclude(0, playlist.length, currentPlaylistItemIndex)
        : currentPlaylistItemIndex + 1;
    newIndex %= playlist.length;
    await setPlaylistIndex(newIndex);
  }

  playPrevious() async {
    if (playlist.length == 1) {
      await replay();
      return;
    }

    int newIndex = shuffle
        ? getRandomIntExclude(0, playlist.length, currentPlaylistItemIndex)
        : currentPlaylistItemIndex - 1 + playlist.length;
    newIndex %= playlist.length;
    await setPlaylistIndex(newIndex);
  }

  pause() async {
    await _player.pause();
  }

  resume() async {
    await _player.play();
  }

  stop() async {
    await _player.stop();
  }

  togglePlayback() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  increaseVolume() async {
    await _player.setVolume(_player.volume + volumeStep);
  }

  decreaseVolume() async {
    await _player.setVolume(_player.volume - volumeStep);
  }

  seek(double position) async {
    await _player.seek(Duration(seconds: position.toInt()));
  }

  nextLoopMode() {
    switch (loopMode) {
      case LoopMode.all:
        loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        loopMode = LoopMode.off;
        break;
      case LoopMode.off:
        loopMode = LoopMode.all;
        break;
    }
  }

  addItemsToPlaylist(List<String> filePaths) {
    playlist.addAll(filePaths);
  }

  replacePlaylist(List<String> filePaths) {
    playlist = filePaths;
    currentPlaylistItemIndex = 0;
    playFile(playlist.first, addToPlaylist: false);
  }
}
