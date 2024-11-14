import 'dart:io';
import 'package:darted_cli/helpers/io/directory/methods/directory_methods.exports.dart';
import 'package:darted_cli/models/io/exception.model.dart';

Future<void> changeWorkingDirectory(String newPath) async {
  if (await directoryExists(newPath)) {
    // Set the new path after a delay to simulate async operation
    await Future.delayed(Duration(milliseconds: 10));
    Directory.current = newPath;
  } else {
    throw DirectoryDoesntExist(path: newPath);
  }
}
