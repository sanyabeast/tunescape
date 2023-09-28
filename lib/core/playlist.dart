import 'dart:io';

class PlaylistManager {
  static final PlaylistManager _instance = PlaylistManager();
  static PlaylistManager get instance => _instance;

  /// Parses the M3U8 playlist and returns a list of file paths.
  List<String> parseM3U8(String content) {
    List<String> paths = [];

    // Splitting by newline to read each line
    List<String> lines = content.split('\n');

    for (String line in lines) {
      // M3U8 files may contain lines starting with '#' as metadata.
      // We're only interested in lines that don't start with '#', as they contain the file paths.
      if (!line.startsWith('#') && line.trim().isNotEmpty) {
        paths.add(line.trim());
      }
    }

    return paths;
  }

  /// Loads an M3U8 playlist from the given file path and returns a list of music file paths.
  Future<List<String>> loadPlaylist(String filePath) async {
    try {
      final file = File(filePath);
      String content = await file.readAsString();
      return parseM3U8(content);
    } catch (e) {
      print('Error loading playlist: $e');
      return [];
    }
  }
}
