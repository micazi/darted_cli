import 'dart:io';

import '../../../../models/io/exception.model.dart';
import 'file_exists.dart';

/// Move a folder to a new path
Future<void> moveFile(String oldPath, String newPath) async {
  if (await fileExists(oldPath)) {
    await File(oldPath).rename(newPath);
  } else {
    throw FileDoesntExist(path: oldPath);
  }
}
