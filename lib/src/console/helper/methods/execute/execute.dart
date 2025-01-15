import 'dart:convert';
import 'dart:io';
import 'parse_args.dart';

Future<dynamic> executeCommandImpl(String commandWithArgs) async {
  try {
    // Parse the command and arguments
    final commandArgs = parseArguments(commandWithArgs);

    // Start the process
    final process = await Process.start(
      commandArgs[0],
      commandArgs.sublist(1),
      runInShell: Platform.isWindows,
    );

    // Handle stdout in real-time
    process.stdout.transform(utf8.decoder).listen((data) {
      stdout.write(data);
    });

    // Handle stderr in real-time
    process.stderr.transform(utf8.decoder).listen((data) {
      stderr.write(data);
    });

    // Wait for the process to complete and check exit code
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw 'Process exited with code $exitCode';
    }
  } catch (e) {
    throw e.toString();
  }
}
