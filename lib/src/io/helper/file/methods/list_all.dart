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

    // get the directories
    final List<File> files = entities.whereType<File>().toList();

    for (var file in files) {
      String name = file.uri.pathSegments.last;

      // Check if the file should be excluded based on RegExp patterns
      if (excluded != null &&
          excluded.isNotEmpty &&
          excluded.any((pattern) => pattern.hasMatch(name))) {
        files.remove(file);
      }

      // Check if the file is allowed by "allowed" patterns
      if (allowed != null &&
          allowed.isNotEmpty &&
          allowed.every((pattern) => !pattern.hasMatch(name))) {
        files.remove(file);
      }
    }

    if (!includeHidden) {
      files.removeWhere(
          (d) => d.path.split(Platform.pathSeparator).last.startsWith('.'));
    }

    return files;
  } else {
    throw DirectoryDoesntExist(path: rootPath);
  }
}
