import 'dart:io';
import 'dart:typed_data';

import 'methods/file_methods.exports.dart';

class FileHelper {
  /// Checks if the file exists.
  Future<bool> exists(String path) async => await fileExists(path);

  /// Creates a file at the specified path (The file's name is the last is that path).
  Future<File> create(String path, {bool? createFoldersInPath}) async => await createFile(path, createFoldersInPath: createFoldersInPath);

  /// Rename the file
  Future<void> rename(String path, String newName) async => await renameFile(path, newName);

  /// Moves a file to a new path
  Future<void> move(String oldPath, String newPath) async => await moveFile(oldPath, newPath);

  // Delete the file in the path [Learn moew about what recursive do!]
  Future<void> delete(String path, {bool? recursive}) async => await deleteFile(path, recursive: recursive);

  /// Write content to a file as String. File will be created if it doesn't exist.
  Future<void> writeString(String path, String content, {bool rewrite = true}) async => await writeStringToFile(path, content, rewrite: true);

  /// Write content to a file as bytes (Uint8List). File will be created if it doesn't exist.
  Future<void> writeBytes(String path, Uint8List content, {bool rewrite = true}) async => await writeBytesToFile(path, content, rewrite: true);

  /// Read the content of a file as String
  Future<String> readAsString(String path) async => await readFileContentAsString(path);

  /// Read the content of a file as bytes (Uint8List)
  Future<Uint8List> readAsBytes(String path) async => await readFileContentAsBytes(path);
}
