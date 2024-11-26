import 'dart:io';

import '../../../../../io_helper.dart';

Future<void> copyImpl(String directoryPath, String toPath) async {
  final source = Directory(directoryPath);
  final destination = Directory(toPath);

  // Assert that the source path exists
  if (!await source.exists()) {
    throw DirectoryDoesntExist(path: source.path);
  }

  // Ensure destination directory exists
  if (!await destination.exists()) {
    await destination.create(recursive: true);
  }

  // Execute the shell command
  if (Platform.isWindows) {
    // Windows: Use `xcopy` command
    await Process.run('xcopy', [
      directoryPath,
      toPath,
      '/E', // Copies all subdirectories, even if empty
      '/I', // Assumes the destination is a directory
      '/Q', // Quiet mode, suppresses output
      '/Y', // Suppresses prompt to confirm overwriting
    ]);
  } else {
    // Unix-based systems: Use `cp` command
    await Process.run('cp', [
      '-r', // Recursive copy
      directoryPath,
      toPath,
    ]);
  }
}
