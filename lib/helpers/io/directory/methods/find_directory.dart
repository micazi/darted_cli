import 'dart:io';
import 'package:darted_cli/models/io/exception.model.dart';

/// Searches for a directory with a search query.
Future<List<String>> searchDirectoriesByName(String rootPath, String name, {bool exactMatch = true}) async {
  final matches = <String>[];
  final dir = Directory(rootPath);

  if (await dir.exists()) {
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is Directory) {
        final dirName = entity.uri.pathSegments.last;
        // Check for exact or partial match based on the exactMatch parameter
        final isMatch = exactMatch ? dirName == name : dirName.contains(name);
        if (isMatch) {
          matches.add(entity.path);
        }
      }
    }
  } else {
    throw DirectoryDoesntExist(path: rootPath);
  }
  return matches;
}
