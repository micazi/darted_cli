import 'dart:io';
import 'package:darted_cli/models/io/exception.model.dart';

Future<Map<String, (int matchLine, String lineContent)>> searchFiles(String rootPath, RegExp query, {bool exactMatch = false}) async {
  final Map<String, (int matchLine, String lineContent)> matches = {};
  final dir = Directory(rootPath);

  if (await dir.exists()) {
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final lines = await entity.readAsLines();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (query.hasMatch(line)) {
            // Add match with file path and line number to the results
            matches.addEntries([MapEntry(entity.path, (i + 1, line.trim()))]);
          }
        }
      }
    }
  } else {
    throw DirectoryDoesntExist(path: rootPath);
  }
  return matches;
}
