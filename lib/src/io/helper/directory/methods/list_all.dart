import '../../../../../io_helper.dart';
import 'directory_exists.dart';

Future<List<Directory>> listAllImpl(
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

    // Collect all directories in the directory
    final List<Directory> dirs = [];
    await for (var entity in entities) {
      if (entity is Directory) {
        dirs.add(entity);
      }
    }

    // Create a list to hold directories to remove
    final List<Directory> dirsToRemove = [];

    for (var dir in dirs) {
      String name = dir.uri.pathSegments.last;

      // Check if the directory should be excluded based on RegExp patterns
      if (excluded != null &&
          excluded.isNotEmpty &&
          excluded.any((pattern) => pattern.hasMatch(name))) {
        dirsToRemove.add(dir);
      }

      // Check if the directory is allowed by "allowed" patterns
      if (allowed != null &&
          allowed.isNotEmpty &&
          allowed.every((pattern) => !pattern.hasMatch(name))) {
        dirsToRemove.add(dir);
      }
    }

    // Remove directories that match any exclusion criteria
    dirs.removeWhere((dir) => dirsToRemove.contains(dir));

    if (!includeHidden) {
      dirs.removeWhere(
          (dir) => dir.path.split(Platform.pathSeparator).last.startsWith('.'));
    }

    return dirs;
  } else {
    throw DirectoryDoesntExist(path: rootPath);
  }
}
