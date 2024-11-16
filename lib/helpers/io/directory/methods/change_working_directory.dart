import 'dart:io';
import 'directory_methods.exports.dart';
import '../../../../models/io/exception.model.dart';

Future<void> changeWorkingDirectory(String newPath) async {
  if (await directoryExists(newPath)) {
    // Set the new path after a delay to simulate async operation
    await Future.delayed(const Duration(milliseconds: 10));
    Directory.current = newPath;
  } else {
    throw DirectoryDoesntExist(path: newPath);
  }
}
