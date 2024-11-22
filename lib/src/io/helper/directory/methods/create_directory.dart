import 'dart:io';

import 'directory_exists.dart';

/// Creates a directory at the specified path (The directory's name is the last is that path).
Future<Directory> createDirectory(String path) async {
  final Directory directory = Directory(path);
  //
  if (!await directoryExists(path)) {
    await directory.create(recursive: true);
  }
  //
  return directory;
}
