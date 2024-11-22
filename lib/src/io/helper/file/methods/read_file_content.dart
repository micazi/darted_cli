import 'dart:io';
import 'dart:typed_data';
import 'file_exists.dart';
import '../../../models/exception.model.dart';

/// Read the content of a file as String
Future<String> readFileContentAsString(String path) async {
  if (await fileExists(path)) {
    return await File(path).readAsString();
  } else {
    throw FileDoesntExist(path: path);
  }
}

/// Read the content of a file as bytes (Uint8List)
Future<Uint8List> readFileContentAsBytes(String path) async {
  if (await fileExists(path)) {
    return await File(path).readAsBytes();
  } else {
    throw FileDoesntExist(path: path);
  }
}
