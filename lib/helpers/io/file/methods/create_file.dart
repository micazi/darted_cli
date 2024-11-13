import 'dart:io';

import 'file_exists.dart';

/// Creates a file at the specified path (The file's name is the last is that path).
Future<File> createFile(String path, {bool? createFoldersInPath = true}) async {
  final File file = File(path);
  //
  if (!await fileExists(path)) {
    await file.create(recursive: createFoldersInPath!);
  }
  //
  return file;
}
