import 'dart:io';

import '../../../models/exception.model.dart';
import 'directory_exists.dart';

/// moves a directory to a new path.
Future<void> moveDirectory(String oldPath, String newPath) async {
  if (!await directoryExists(newPath)) {
    throw DirectoryDoesntExist(path: newPath);
  }
  if (await directoryExists(oldPath)) {
    String folderName = oldPath.split(Platform.pathSeparator).last;
    String newPathed = "$newPath${Platform.pathSeparator}$folderName";
    await Directory(oldPath).rename(newPathed);
  } else {
    throw DirectoryDoesntExist(path: oldPath);
  }
}
