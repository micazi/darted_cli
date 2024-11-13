import 'dart:io';
import 'dart:typed_data';

/// Write content to a file as String. File will be created if it doesn't exist.
Future<void> writeStringToFile(String path, String content, {bool rewrite = true}) async {
  File file = File(path);
  await file.writeAsString(content, mode: rewrite ? FileMode.append : FileMode.write);
}

/// Write content to a file as bytes (Uint8List). File will be created if it doesn't exist.
Future<void> writeBytesToFile(String path, Uint8List content, {bool rewrite = true}) async {
  File file = File(path);
  await file.writeAsBytes(content, mode: rewrite ? FileMode.append : FileMode.write);
}
