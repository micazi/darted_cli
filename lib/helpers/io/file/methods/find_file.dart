import 'dart:io';

import '../../directory/methods/directory_methods.exports.dart';
import '../../../../models/io/exception.model.dart';

/// Searches for a file with a search query.
Future<List<String>> findFilesByName(String rootPath, String name, {bool exactMatch = true, bool ignoreHidden = true}) async {
  final matches = <String>[];
  final dir = Directory(rootPath);

  if (await directoryExists(rootPath)) {
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File && (!ignoreHidden || (!entity.path.split(Platform.pathSeparator).last.startsWith('.')))) {
        final fileName = entity.path.split(Platform.pathSeparator).last;
        // Check for exact or partial match based on the exactMatch parameter
        final isMatch = exactMatch ? fileName.trim() == name.trim() : fileName.trim().contains(name.trim());
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

/// Searches for a file by a RegExp pattern.
Future<List<String>> findFilesByPattern(String rootPath, RegExp pattern, {bool ignoreHidden = true}) async {
  final matches = <String>[];
  final dir = Directory(rootPath);

  if (await directoryExists(rootPath)) {
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File && (!ignoreHidden || !entity.path.split(Platform.pathSeparator).last.startsWith('.'))) {
        final dirName = entity.path.split(Platform.pathSeparator).last;
        // Check for match with the RegExp pattern
        if (pattern.hasMatch(dirName)) {
          matches.add(entity.path);
        }
      }
    }
  } else {
    throw DirectoryDoesntExist(path: rootPath);
  }
  return matches;
}
