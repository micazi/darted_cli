import 'dart:io';

import '../../directory/methods/directory_methods.exports.dart';
import '../../../../models/io/exception.model.dart';

import 'file_exists.dart';

/// Creates a file at the specified path (The file's name is the last is that path).
Future<File> createFile(String path, {bool createFoldersInPath = true}) async {
  String fileName = path.split(Platform.pathSeparator).last;
  String directoryPath = path.replaceAll("${Platform.pathSeparator}$fileName", '');
  bool directoryPathExists = await directoryExists(directoryPath);
  if (!directoryPathExists) {
    throw DirectoryDoesntExist(path: directoryPath);
  }
  //
  final File file = File(path);
  //
  if (!await fileExists(path)) {
    await file.create(recursive: createFoldersInPath);
  }
  //
  return file;
}
