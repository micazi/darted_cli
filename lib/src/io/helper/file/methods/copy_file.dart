import '../../../../../io_helper.dart';

Future<void> copyImpl(String filePath, String destinationFilePath,
    {bool createDestination = true}) async {
  // Ensure the source file exists
  if (!await File(filePath).exists()) {
    throw FileDoesntExist(path: filePath);
  }

  // Ensure the destination directory exists
  Directory destinationDir = Directory(File(destinationFilePath).parent.path);
  if (!await destinationDir.exists()) {
    if (createDestination) {
      await destinationDir.create(recursive: true);
    } else {
      throw DirectoryDoesntExist(path: destinationDir.path);
    }
  }

  // Use Dart's File class to copy the file
  try {
    await File(filePath).copy(destinationFilePath);
  } catch (e) {
    // Handle any errors that occur during the copy operation
    throw ('Error copying file: $e');
  }
}
