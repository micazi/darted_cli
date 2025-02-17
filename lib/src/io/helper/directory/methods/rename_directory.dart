import 'dart:io';
import 'directory_methods.exports.dart';
import '../../../models/exception.model.dart';

/// Rename the directory.
Future<void> renameDirectory(String path, String newFileName) async {
  if (await directoryExists(path)) {
    int lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    await Directory(path).rename(newPath);
  } else {
    throw DirectoryDoesntExist(path: path);
  }
}
