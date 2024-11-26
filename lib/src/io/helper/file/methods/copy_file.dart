import 'dart:io';

import '../../../../../io_helper.dart';

Future<void> copyImpl(String filePath, String destinationFilePath,
    {bool createDestination = true}) async {
  // Ensure the source file exists
  if (!await IOHelper.file.exists(filePath)) {
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

  // Determine the shell command based on the operating system
  String command;
  if (Platform.isWindows) {
    // Windows command
    command = 'copy "$filePath" "$destinationFilePath"';
  } else {
    // Unix-based systems command
    command = 'cp "$filePath" "$destinationFilePath"';
  }

  // Execute the command
  await Process.run(
    Platform.isWindows ? 'cmd' : 'bash',
    Platform.isWindows ? ['/c', command] : ['-c', command],
  );
}
