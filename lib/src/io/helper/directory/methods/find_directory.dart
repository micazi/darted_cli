import 'dart:io';
import '../../../models/exception.model.dart';

/// Searches for a directory with a search query.
Future<List<String>> findDirectoriesByName(String rootPath, String name,
    {bool exactMatch = true, bool ignoreHidden = true}) async {
  final matches = <String>[];

  final dir = Directory(rootPath);

  if (await dir.exists()) {
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is Directory &&
          (!ignoreHidden ||
              (!entity.path
                  .split(Platform.pathSeparator)
                  .last
                  .startsWith('.')))) {
        final dirName = entity.path.split(Platform.pathSeparator).last;
        // Check for exact or partial match based on the exactMatch parameter
        final isMatch = exactMatch
            ? dirName.trim() == name.trim()
            : dirName.trim().contains(name.trim());
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

/// Find directory by a RegExp pattern.
Future<List<String>> findDirectoriesByPattern(String rootPath, RegExp pattern,
    {bool ignoreHidden = true}) async {
  final matches = <String>[];
  final dir = Directory(rootPath);

  if (await dir.exists()) {
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is Directory &&
          (!ignoreHidden ||
              !entity.path
                  .split(Platform.pathSeparator)
                  .last
                  .startsWith('.'))) {
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
