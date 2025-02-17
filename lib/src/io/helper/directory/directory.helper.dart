import 'dart:io';
import '../io.helper.dart';
import 'methods/directory_methods.exports.dart';

class DirectoryHelper {
  /// Get the current working directory.
  String getCurrent() => getCurrentWorkingDirectory();

  /// Change the current working directory to a new path.
  Future<void> change(String newPath) async =>
      await changeWorkingDirectory(newPath.replaceSeparator());

  /// Checks if the directory exists.
  Future<bool> exists(String path) async =>
      await directoryExists(path.replaceSeparator());

  /// List all the directories in this root directory.
  Future<List<Directory>> listAll(
    String rootPath, {
    bool includeHidden = false,
    bool recurse = false,
    bool followLinks = false,
    List<RegExp>? excluded,
    List<RegExp>? allowed,
  }) async =>
      await listAllImpl(
        rootPath,
        includeHidden: includeHidden,
        recurse: recurse,
        followLinks: followLinks,
        excluded: excluded,
        allowed: allowed,
      );

  /// Search for a directory by it's name.
  Future<List<String>> find(String rootPath, String name,
          {bool isExactMatch = false, bool ignoreHidden = true}) async =>
      await findDirectoriesByName(rootPath.replaceSeparator(), name,
          exactMatch: isExactMatch, ignoreHidden: ignoreHidden);

  /// Search for a directory with a RegExp pattern.
  Future<List<String>> findAdvanced(String rootPath, RegExp pattern,
          {bool isExactMatch = false, bool ignoreHidden = true}) async =>
      await findDirectoriesByPattern(rootPath.replaceSeparator(), pattern,
          ignoreHidden: ignoreHidden);

  /// Creates a directory at the specified path (The directory's name is the last is that path).
  Future<Directory> create(String path) async =>
      await createDirectory(path.replaceSeparator());

  /// Rename the directory
  Future<void> rename(String path, String newName) async =>
      await renameDirectory(path.replaceSeparator(), newName);

  /// Copies a directory to a new path
  Future<void> copy(String directoryPath, String destinationPath) async =>
      await copyImpl(
          directoryPath.replaceSeparator(), destinationPath.replaceSeparator());

  /// Moves a directory to a new path
  Future<void> move(String oldPath, String newPath) async =>
      await moveDirectory(
          oldPath.replaceSeparator(), newPath.replaceSeparator());

  // Delete the directory at path [Learn moew about what recursive do!]
  Future<void> delete(String path, {bool recursive = false}) async =>
      await deleteDirectory(path.replaceSeparator(), recursive: recursive);
}
