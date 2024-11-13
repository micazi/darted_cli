import 'dart:io';

/// Checks if the directory exists.
Future<bool> directoryExists(String path) async {
  final directory = Directory(path);
  return await directory.exists();
}
