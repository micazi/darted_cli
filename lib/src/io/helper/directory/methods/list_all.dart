import 'dart:io';
import '../../../../../io_helper.dart';
import 'directory_exists.dart';

Future<List<Directory>> listAllImpl(String rootPath,
    {bool includeHidden = false}) async {
  // The root directory
  final directory = Directory(rootPath);

  if (await directoryExists(rootPath)) {
    // List all entities in the directory
    final entities = await directory.list().toList();

    // get the directories
    final List<Directory> dirs = entities.whereType<Directory>().toList();

    if (!includeHidden) {
      dirs.removeWhere(
          (d) => d.path.split(Platform.pathSeparator).last.startsWith('.'));
    }

    return dirs;
  } else {
    throw DirectoryDoesntExist(path: rootPath);
  }
}
