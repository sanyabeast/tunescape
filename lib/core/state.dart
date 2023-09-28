import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double leftSectionWidth = 360;
const double bottomSectionHeight = 150;
const int _saveDebounceTimeout = 5;

const supportedAudiofileExtensions = [
  "mp3",
  "m4a",
  "aac",
  "wav",
  "flac",
  "ogg",
  "oga",
];

const supportedPlaylistExtensions = ["m3u8"];

class TsColorScheme {
  late MaterialColor swatch;
  late MaterialAccentColor accent;
  TsColorScheme(this.swatch, this.accent);
}

List<TsColorScheme> accentColors = [
  TsColorScheme(Colors.red, Colors.redAccent),
  TsColorScheme(Colors.orange, Colors.orangeAccent),
  TsColorScheme(Colors.amber, Colors.amberAccent),
  TsColorScheme(Colors.yellow, Colors.yellowAccent),
  TsColorScheme(Colors.lime, Colors.limeAccent),
  TsColorScheme(Colors.green, Colors.greenAccent),
  TsColorScheme(Colors.teal, Colors.tealAccent),
  TsColorScheme(Colors.cyan, Colors.cyanAccent),
  TsColorScheme(Colors.blue, Colors.blueAccent),
  TsColorScheme(Colors.indigo, Colors.indigoAccent),
  TsColorScheme(Colors.purple, Colors.purpleAccent),
  TsColorScheme(Colors.pink, Colors.pinkAccent),

  // ... add more colors here
];

// Sort the colors based on their hue

class TsThemeManager {
  int colorSchemeIndex = 0;

  TsColorScheme get colors => accentColors[colorSchemeIndex];

  setColorScheme(TsColorScheme colors) {
    colorSchemeIndex = accentColors.indexOf(colors);
    accentColorNotifier.colors = colors;
  }

  setColorSchemeIndex(int index) {
    colorSchemeIndex = index;
    accentColorNotifier.colors = colors;
    preferences.set('colorSchemeIndex', index);
  }

  init() {
    setColorSchemeIndex(preferences.getOrDefault('colorSchemeIndex', 0));
  }

  reset() {
    setColorSchemeIndex(0);
  }
}

class AccentColorNotifier with ChangeNotifier {
  TsColorScheme _colors = accentColors.first; // Default color

  TsColorScheme get colors => _colors;

  set colors(TsColorScheme color) {
    _colors = color;
    notifyListeners();
  }
}

final accentColorNotifier = AccentColorNotifier();

class TsPreferences {
  late SharedPreferences _prefs;
  Map<String, dynamic> _data = {};
  bool _unsaved = false;
  Timer? _saveTimer;

  init() async {
    _prefs = await SharedPreferences.getInstance();
    await load();
  }

  set<T>(String key, T value) {
    if (_data[key] == value) {
      return;
    }

    print("TsPreferences: setting $key to $value");

    _data[key] = value;
    _unsaved = true;
  }

  T? get<T>(String key) {
    return _data[key];
  }

  T getOrDefault<T>(String key, T defaultValue) {
    if (_data[key] == null) {
      _data[key] = defaultValue;
      return defaultValue;
    } else {
      return _data[key];
    }
  }

  save() {
    _unsaved = false;

    if (_saveTimer != null) {
      _saveTimer!.cancel();
    }

    _saveTimer = Timer(const Duration(seconds: _saveDebounceTimeout), () async {
      await _save();
    });
  }

  _save() async {
    print("TsPreferences: saving - ${jsonEncode(_data)}");
    await _prefs.setString('tunescape', jsonEncode(_data));
  }

  load() async {
    var data = _prefs.getString('tunescape');
    if (data != null) {
      _data = jsonDecode(data);
      print("TsPreferences: loaded - ${jsonEncode(_data)}");
    }
  }

  reset() {
    _data = {};
    _unsaved = true;
    save();
  }

  tick() {
    if (_unsaved) {
      print("TsPreferences: tick, unsaved state detected");
      save();
    }
  }
}

TsThemeManager themeManager = TsThemeManager();
TsPreferences preferences = TsPreferences();
