import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunescape/core/tools.dart';

class PlaybackManager {
  final AudioPlayer _player = AudioPlayer();

  static final PlaybackManager _instance = PlaybackManager();
  static PlaybackManager get instance => _instance;

  double get volume => _player.volume;
  set volume(double value) => _player.setVolume(clampDouble(value, 0, 1));

  LoopMode get loopMode => _player.loopMode;
  set loopMode(LoopMode value) => _player.setLoopMode(value);

  double volumeStep = 0.1;

  bool get isPlaying => _player.playing;

  bool shuffle = false;

  bool get isEmpty => playlist.isEmpty;
  bool get isSingle => playlist.length == 1;

  double get playbackDuration => _player.duration?.inSeconds?.toDouble() ?? 0.0;
  double get playbackPosition => _player.position?.inSeconds?.toDouble() ?? 0.0;

  bool get isMuted => _player.volume <= 0.0;
  set isMuted(bool value) => _player.setVolume(value ? 0.0 : 1.0);

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

  playFile(String filePath, {bool addToPlaylist = true}) async {
    if (_player.playing) {
      await _player.stop();
    }

    currentFilePath = filePath;

    if (addToPlaylist) {
      playlist.add(filePath);
      currentPlaylistItemIndex = playlist.length - 1;
    }

    await _player.setFilePath(filePath);
    await _player.play();
    await _player.setVolume(volume);
  }

  setPlaylistIndex(int index) async {
    if (index < 0 || index >= playlist.length) {
      return;
    }

    currentPlaylistItemIndex = index;
    await playFile(playlist[index], addToPlaylist: false);
  }

  playNext() async {
    int newIndex = shuffle
        ? getRandomIntExclude(0, playlist.length, currentPlaylistItemIndex)
        : currentPlaylistItemIndex + 1;
    newIndex %= playlist.length;
    await setPlaylistIndex(newIndex);
  }

  playPrevious() async {
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

  dispose() async {
    await _player.dispose();
  }

  seek(double position) async {
    await _player.seek(Duration(seconds: position.toInt()));
  }

  nextLoopMode() {
    switch (_player.loopMode) {
      case LoopMode.off:
        _player.setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        _player.setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        _player.setLoopMode(LoopMode.off);
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

  Stream<Duration?> get positionStream => _player.positionStream;

  Stream<Duration?> get durationStream => _player.durationStream;

  Stream<ProcessingState?> get processingStateStream => _player.processingStateStream;

  Stream<SequenceState?> get sequenceStateStream => _player.sequenceStateStream;

  Stream<LoopMode?> get loopModeStream => _player.loopModeStream;
}
