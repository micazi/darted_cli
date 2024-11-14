import 'dart:io';

import '../../../models/io/exception.model.dart';
import '../directory/methods/directory_methods.exports.dart';

Future<void> listTree(
  String path, {
  indent = '',
  bool isLast = true,
  String? separatorColor,
  String? fileColor,
  String? folderColor,
  //
  bool withHiddenDirectories = false,
  bool withHiddenFiles = true,
}) async {
  final directory = Directory(path);
  //
  if (await directoryExists(path)) {
    // Print the root directory itself with the custom folder color
    final name = path.split(Platform.pathSeparator).last;
    print('$indent${isLast ? '└── ' : '├── '}$folderColor$name\x1B[0m/');

    // List all entities in the directory
    final entities = await directory.list().toList();

    // Separate files and directories
    final files = entities.whereType<File>().toList();
    final dirs = entities.whereType<Directory>().toList();
    if (!withHiddenDirectories) {
      dirs.removeWhere((d) => d.path.split(Platform.pathSeparator).last.startsWith('.'));
    }

    if (!withHiddenFiles) {
      files.removeWhere((f) => f.path.split(Platform.pathSeparator).last.startsWith('.'));
    }

    // First, print files with the custom file color
    for (var file in files) {
      final fileName = file.uri.pathSegments.last;
      print('$indent    └── $fileColor$fileName\x1B[0m');
    }

    // Then, print directories (recurse into them) with the custom folder color
    for (int i = 0; i < dirs.length; i++) {
      final dir = dirs[i];

      // Calculate the next indent level and whether it's the last directory
      final nextIndent = '$indent${isLast ? '    ' : '│   '}';
      final isLastDir = i == dirs.length - 1;

      // Recurse into subdirectories
      await listTree(
        dir.path,
        indent: nextIndent,
        isLast: isLastDir,
        separatorColor: separatorColor,
        fileColor: fileColor,
        folderColor: folderColor,
      );
    }
  } else {
    throw DirectoryDoesntExist(path: path);
  }
}
