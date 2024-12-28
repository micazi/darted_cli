import '../../../../../io_helper.dart';
import '../../directory/methods/directory_exists.dart';

Future<List<File>> listAllImpl(
  String rootPath, {
  bool includeHidden = false,
  bool recurse = true,
  bool followLinks = false,
  List<RegExp>? excluded,
  List<RegExp>? allowed,
}) async {
  // The root directory
  final directory = Directory(rootPath);

  if (await directoryExists(rootPath)) {
    // List all entities in the directory recursively
    final entities =
        directory.list(recursive: recurse, followLinks: followLinks);

    // Collect all files in the directory
    final List<File> files = [];
    await for (var entity in entities) {
      if (entity is File) {
        files.add(entity);
      }
    }

    // Create a list to hold files to remove
    final List<File> filesToRemove = [];

    for (var file in files) {
      String name = file.uri.pathSegments.last;

      // Check if the file should be excluded based on RegExp patterns
      if (excluded != null &&
          excluded.isNotEmpty &&
          excluded.any((pattern) => pattern.hasMatch(name))) {
        filesToRemove.add(file);
      }

      // Check if the file is allowed by "allowed" patterns
      if (allowed != null &&
          allowed.isNotEmpty &&
          allowed.every((pattern) => !pattern.hasMatch(name))) {
        filesToRemove.add(file);
      }
    }

    // Remove files that match any exclusion criteria
    files.removeWhere((file) => filesToRemove.contains(file));

    if (!includeHidden) {
      files.removeWhere((file) =>
          file.path.split(Platform.pathSeparator).last.startsWith('.'));
    }

    return files;
  } else {
    throw DirectoryDoesntExist(path: rootPath);
  }
}
