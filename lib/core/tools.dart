import 'package:flutter/material.dart';

String getFileName(String filePath) {
  return filePath.split(RegExp(r'[/\\]+')).last;
}

String formatDuration(int seconds) {
  final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
  final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final secs = (seconds % 60).toString().padLeft(2, '0');

  return "$hours:$minutes:$secs";
}

Widget createColoredBox(Color color) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    color: color,
  );
}

int getRandomInt(int min, int max) {
  return min + (max - min) * (DateTime.now().millisecondsSinceEpoch % 1000) ~/ 1000;
}

int getRandomIntExclude(int min, int max, int exclude) {
  if (max - min <= 1) {
    return min;
  }

  int result = getRandomInt(min, max);
  while (result == exclude) {
    result = getRandomInt(min, max);
  }
  return result;
}
