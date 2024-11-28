import '../../../../../io_helper.dart';
import '../../directory/methods/directory_exists.dart';

Future<List<File>> listAllImpl(String rootPath,
    {bool includeHidden = false}) async {
  // The root directory
  final directory = Directory(rootPath);

  if (await directoryExists(rootPath)) {
    // List all entities in the directory
    final entities = await directory.list().toList();

    // get the directories
    final List<File> files = entities.whereType<File>().toList();

    if (!includeHidden) {
      files.removeWhere(
          (d) => d.path.split(Platform.pathSeparator).last.startsWith('.'));
    }

    return files;
  } else {
    throw DirectoryDoesntExist(path: rootPath);
  }
}
