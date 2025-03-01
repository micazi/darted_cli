import 'dart:io';
import 'dart:typed_data';
import '../io.helper.dart';
import 'methods/file_methods.exports.dart';

class FileHelper {
  /// Checks if the file exists.
  Future<bool> exists(String path) async =>
      await fileExists(path.replaceSeparator());

  /// List all the files in this root directory.
  Future<List<File>> listAll(
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

  /// Search for a file bu it's name.
  Future<List<String>> find(String rootPath, String name,
          {bool isExactMatch = false, bool ignoreHidden = true}) async =>
      await findFilesByName(rootPath.replaceSeparator(), name,
          exactMatch: isExactMatch, ignoreHidden: ignoreHidden);

  /// Search for a file with a RegExp pattern.
  Future<List<String>> findAdvanced(String rootPath, RegExp pattern,
          {bool ignoreHidden = true}) async =>
      await findFilesByPattern(rootPath.replaceSeparator(), pattern,
          ignoreHidden: ignoreHidden);

  /// Search through all the files for a RegExp pattern.
  Future<
      Map<
          String,
          List<
              (
                int matchLine,
                String lineContent,
                Map<int, String> matchPositions
              )>>> search(String rootPath, RegExp pattern,
          {bool ignoreHidden = true,
          List<RegExp> excluded = const [],
          List<RegExp> allowed = const []}) async =>
      await searchFilesContent(rootPath.replaceSeparator(), pattern,
          ignoreHidden: ignoreHidden, excluded: excluded, allowed: allowed);

  /// Search the content of files in a root path for a RegExp pattern and replace it.
  Future<
      Map<
          String,
          List<
              (
                int matchLine,
                String lineContent,
                Map<int, String> matchPositions
              )>>> searchAndReplace(String rootPath, RegExp pattern,
          {bool ignoreHidden = true,
          List<RegExp> excluded = const [],
          List<RegExp> allowed = const [],
          String? replacement}) async =>
      await searchFilesContent(rootPath.replaceSeparator(), pattern,
          ignoreHidden: ignoreHidden,
          excluded: excluded,
          allowed: allowed,
          replacement: replacement);

  /// Creates a file at the specified path (The file's name is the last is that path).
  Future<File> create(String path, {bool createFoldersInPath = true}) async =>
      await createFile(path.replaceSeparator(),
          createFoldersInPath: createFoldersInPath);

  /// Rename the file
  Future<void> rename(String path, String newName) async =>
      await renameFile(path.replaceSeparator(), newName);

  /// Copies a file from source path to a new path
  Future<void> copy(String filePath, String newPath) async =>
      await copyImpl(filePath.replaceSeparator(), newPath.replaceSeparator());

  /// Moves a file to a new path
  Future<void> move(String oldPath, String newPath) async =>
      await moveFile(oldPath.replaceSeparator(), newPath.replaceSeparator());

  // Delete the file in the path [Learn moew about what recursive do!]
  Future<void> delete(String path, {bool recursive = false}) async =>
      await deleteFile(path.replaceSeparator(), recursive: recursive);

  /// Write content to a file as String. File will be created if it doesn't exist.
  Future<void> writeString(String path, String content,
          {bool rewrite = true}) async =>
      await writeStringToFile(path.replaceSeparator(), content,
          rewrite: rewrite);

  /// Write content to a file as bytes (Uint8List). File will be created if it doesn't exist.
  Future<void> writeBytes(String path, Uint8List content,
          {bool rewrite = true}) async =>
      await writeBytesToFile(path.replaceSeparator(), content, rewrite: true);

  /// Read the content of a file as String
  Future<String> readAsString(String path) async =>
      await readFileContentAsString(path.replaceSeparator());

  /// Read the content of a file as bytes (Uint8List)
  Future<Uint8List> readAsBytes(String path) async =>
      await readFileContentAsBytes(path.replaceSeparator());
}
