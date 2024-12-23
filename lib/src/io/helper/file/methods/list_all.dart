import '../../../../../io_helper.dart';
import '../../directory/methods/directory_exists.dart';

Future<List<File>> listAllImpl(
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

    // get the files
    final List<File> files = entities.whereType<File>().toList();

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
      files.removeWhere(
          (d) => d.path.split(Platform.pathSeparator).last.startsWith('.'));
    }

    return files;
  } else {
    throw DirectoryDoesntExist(path: rootPath);
  }
}
