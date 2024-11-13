import 'dart:io';

import 'package:darted_cli/helpers/io/directory/methods/directory_methods.exports.dart';
import '../../../../models/io/exception.model.dart';

/// Searches for a file with a search query.
Future<List<String>> searchFilesByName(String rootPath, String name, {bool exactMatch = true}) async {
  final matches = <String>[];
  final dir = Directory(rootPath);

  if (await directoryExists(rootPath)) {
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final fileName = entity.uri.pathSegments.last;
        // Check for exact or partial match based on the exactMatch parameter
        final isMatch = exactMatch ? fileName == name : fileName.contains(name);
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
