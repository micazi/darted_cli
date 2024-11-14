import 'dart:io';

import 'package:darted_cli/helpers/io/file/methods/file_methods.exports.dart';
import 'package:darted_cli/models/io/exception.model.dart';

/// Deletes a directory with the optional recursive argument.
Future<void> deleteFile(String path, {bool recursive = false}) async {
  if (await fileExists(path)) {
    await File(path).delete(recursive: recursive);
  } else {
    throw FileDoesntExist(path: path);
  }
}
