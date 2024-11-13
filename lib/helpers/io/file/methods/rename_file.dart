import 'dart:io';

import '../../../../models/io/exception.model.dart';
import 'file_exists.dart';

/// Rename the file.
Future<void> renameFile(String path, String newFileName) async {
  if (await fileExists(path)) {
    int lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    await File(path).rename(newPath);
  } else {
    throw FileDoesntExist(path: path);
  }
}
