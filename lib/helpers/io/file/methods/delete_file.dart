import 'dart:io';

import 'file_methods.exports.dart';
import '../../../../models/io/exception.model.dart';

/// Deletes a directory with the optional recursive argument.
Future<void> deleteFile(String path, {bool recursive = false}) async {
  if (await fileExists(path)) {
    await File(path).delete(recursive: recursive);
  } else {
    throw FileDoesntExist(path: path);
  }
}
