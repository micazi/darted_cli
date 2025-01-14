import '../../../../../io_helper.dart';

Future<void> copyImpl(String directoryPath, String toPath,
    {bool createDestination = true}) async {
  final source = Directory(directoryPath);
  final destination = Directory(toPath);

  // Ensure the source directory exists
  if (!await source.exists()) {
    throw DirectoryDoesntExist(path: source.path);
  }

  // Ensure the destination directory exists
  if (!await destination.exists()) {
    if (createDestination) {
      await destination.create(recursive: true);
    } else {
      throw DirectoryDoesntExist(path: destination.path);
    }
  }

  // Recursively copy the directory
  await _copyDirectory(source, destination);
}

Future<void> _copyDirectory(Directory source, Directory destination) async {
  try {
    // List all entities (files and subdirectories) in the source directory
    final entities = source.list(recursive: false);

    await for (final entity in entities) {
      final newPath = entity.path.replaceFirst(source.path, destination.path);

      if (entity is File) {
        // Copy the file
        await entity.copy(newPath);
      } else if (entity is Directory) {
        // Create the subdirectory and copy its contents
        final newDirectory = Directory(newPath);
        await newDirectory.create(recursive: true);
        await _copyDirectory(entity, newDirectory);
      }
    }
  } catch (e) {
    throw ('Error copying directory: $e');
  }
}
