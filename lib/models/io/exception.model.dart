import 'dart:io';

class IOException extends FileSystemException {
  IOException({String? path}) : super('', path);
}

// Directories
class DirectoryDoesntExist extends IOException {
  DirectoryDoesntExist({super.path});
}

// Files
class FileDoesntExist extends IOException {
  FileDoesntExist({super.path});
}
