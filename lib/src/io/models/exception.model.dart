import 'dart:io';

class IOException extends FileSystemException {
  IOException(String message, {String? path}) : super(message, path);
}

// Directories
class DirectoryDoesntExist extends IOException {
  DirectoryDoesntExist({super.path}) : super("Directory Doesn't Exist");
}

// Files
class FileDoesntExist extends IOException {
  FileDoesntExist({super.path}) : super("File Doesn't Exist");
}
