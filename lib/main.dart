import 'package:flutter/material.dart';
// import 'package:metadata_god/metadata_god.dart';
import 'package:tunescape/core/playback.dart';
import 'package:tunescape/core/state.dart';
import 'package:tunescape/widget/player.dart';
import 'package:desktop_window/desktop_window.dart';

GlobalKey playerState = GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await preferences.init();
  await themeManager.init();
  // MetadataGod.initialize();
  await PlaybackManager.instance.init();
  await DesktopWindow.setMinWindowSize(const Size(800, 600));
  runApp(TuneScape());
}

class TuneScape extends StatefulWidget {
  TuneScape({super.key});

  @override
  State<TuneScape> createState() => _TuneScapeState();
}

class _TuneScapeState extends State<TuneScape> {
  MaterialColor _swatchColor = accentColorNotifier.colors.swatch;
  MaterialAccentColor _accentColor = accentColorNotifier.colors.accent;

  @override
  void initState() {
    super.initState();
    accentColorNotifier.addListener(_updateAccentColor);
  }

  _updateAccentColor() {
    setState(() {
      _swatchColor = accentColorNotifier.colors.swatch;
      _accentColor = accentColorNotifier.colors.accent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuneScape',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
          cardColor: const Color.fromARGB(255, 10, 10, 10),
          backgroundColor: const Color.fromARGB(255, 10, 10, 10),
          primarySwatch: _swatchColor,
          accentColor: _accentColor,
          primaryColorDark: Colors.black,
          errorColor: Colors.red,
        ),
      ),
      home: MusicPlayer(key: playerState),
    );
  }

  @override
  void dispose() {
    accentColorNotifier.removeListener(_updateAccentColor);
    super.dispose();
  }
}
