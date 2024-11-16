import 'dart:io';

import '../../directory/methods/directory_methods.exports.dart';

import '../../../../models/io/exception.model.dart';
import 'file_exists.dart';

/// Move a folder to a new path
Future<void> moveFile(String oldPath, String newPath) async {
  if (!await directoryExists(newPath)) {
    throw DirectoryDoesntExist(path: newPath);
  }
  if (await fileExists(oldPath)) {
    String fileName = oldPath.split(Platform.pathSeparator).last;
    String newPathed = "$newPath${Platform.pathSeparator}$fileName";
    await File(oldPath).rename(newPathed);
  } else {
    throw FileDoesntExist(path: oldPath);
  }
}
