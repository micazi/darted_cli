import 'dart:io';

/// Checks if the file exists.
Future<bool> fileExists(String path) async {
  final file = File(path);
  return await file.exists();
}
