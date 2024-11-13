import 'dart:io';

import '../../../../models/io/exception.model.dart';
import 'directory_exists.dart';

/// moves a directory to a new path.
Future<void> moveDirectory(String oldPath, String newPath) async {
  if (await directoryExists(oldPath)) {
    await Directory(oldPath).rename(newPath);
  } else {
    throw DirectoryDoesntExist(path: oldPath);
  }
}
