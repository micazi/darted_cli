import 'dart:io';
import 'methods/directory_methods.exports.dart';

class DirectoryHelper {
  /// Checks if the directory exists.
  Future<bool> exists(String path) async => await directoryExists(path);

  /// Creates a directory at the specified path (The directory's name is the last is that path).
  Future<Directory> create(String path) async => await createDirectory(path);

  /// Rename the directory
  Future<void> rename(String path, String newName) async => await renameDirectory(path, newName);

  /// Moves a directory to a new path
  Future<void> move(String oldPath, String newPath) async => await moveDirectory(oldPath, newPath);

  // Delete the directory at path [Learn moew about what recursive do!]
  Future<void> delete(String path, {bool? recursive}) async => await deleteDirectory(path, recursive: recursive);
}
