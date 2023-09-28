import 'package:flutter/material.dart';
import 'package:tunescape/widget/player.dart';
import 'package:desktop_window/desktop_window.dart';

GlobalKey playerState = GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DesktopWindow.setMinWindowSize(const Size(800, 600));
  runApp(TuneScape());
}

class TuneScape extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuneScape',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
          cardColor: const Color.fromARGB(255, 25, 25, 25),
          backgroundColor: const Color.fromARGB(255, 25, 25, 25),
          primarySwatch: Colors.red,
          accentColor: Colors.redAccent,
        ),
      ),
      home: MusicPlayer(key: playerState),
    );
  }
}
