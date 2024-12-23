import '../../../../../io_helper.dart';
import 'directory_exists.dart';

Future<List<Directory>> listAllImpl(
  String rootPath, {
  bool includeHidden = false,
  List<RegExp>? excluded,
  List<RegExp>? allowed,
}) async {
  // The root directory
  final directory = Directory(rootPath);

  if (await directoryExists(rootPath)) {
    // List all entities in the directory
    final entities = await directory.list().toList();

    // get the directories
    final List<Directory> dirs = entities.whereType<Directory>().toList();

    // Create a list to hold directories to remove
    final List<Directory> dirsToRemove = [];

    for (var directory in dirs) {
      String name = directory.uri.pathSegments.last;

      // Check if the directory should be excluded based on RegExp patterns
      if (excluded != null &&
          excluded.isNotEmpty &&
          excluded.any((pattern) => pattern.hasMatch(name))) {
        dirsToRemove.add(directory);
      }

      // Check if the directory is allowed by "allowed" patterns
      if (allowed != null &&
          allowed.isNotEmpty &&
          allowed.every((pattern) => !pattern.hasMatch(name))) {
        dirsToRemove.add(directory);
      }
    }
    // Remove directories that match any exclusion criteria
    dirs.removeWhere((directory) => dirsToRemove.contains(directory));

    if (!includeHidden) {
      dirs.removeWhere(
          (d) => d.path.split(Platform.pathSeparator).last.startsWith('.'));
    }

    return dirs;
  } else {
    throw DirectoryDoesntExist(path: rootPath);
  }
}
