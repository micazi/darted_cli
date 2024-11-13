import 'dart:io';

import 'package:darted_cli/helpers/io/directory/methods/directory_exists.dart';
import 'package:darted_cli/models/io/exception.model.dart';

/// Deletes a directory with the optional recursive argument.
Future<void> deleteDirectory(String path, {bool? recursive = false}) async {
  if (await directoryExists(path)) {
    await Directory(path).delete(recursive: recursive!);
  } else {
    throw DirectoryDoesntExist(path: path);
  }
}
