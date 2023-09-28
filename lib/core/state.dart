import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const double leftSectionWidth = 300;
const double bottomSectionHeight = 150;
const int _saveDebounceTimeout = 5;

class Preferences {
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

    print("Preferences: setting $key to $value");

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
    print("Preferences: saving - ${jsonEncode(_data)}");
    await _prefs.setString('tunescape', jsonEncode(_data));
  }

  load() async {
    var data = _prefs.getString('tunescape');
    if (data != null) {
      _data = jsonDecode(data);
      print("Preferences: loaded - ${jsonEncode(_data)}");
    }
  }

  tick() {
    if (_unsaved) {
      print("Preferences: tick, unsaved state detected");
      save();
    }
  }
}

Preferences preferences = Preferences();
