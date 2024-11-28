import 'dart:io';

import 'parse_args.dart';

Future<void> executeCommandImpl(String commandWithArgs) async {
  try {
    // Parse the command and arguments
    final commandArgs = parseArguments(commandWithArgs);

    // Run the command
    final result = await Process.run(commandArgs[0], commandArgs.sublist(1));

    // Handle the result (check for errors and print output)
    if (result.exitCode != 0) {
      throw Exception('Command execution failed: ${result.stderr}');
    }

    // Print output
    if (result.stdout.isNotEmpty) {
      print(result.stdout);
    }

    if (result.stderr.isNotEmpty) {
      print('Error: ${result.stderr}');
    }

    print('Command executed successfully: ${commandArgs.join(' ')}');
  } catch (e) {
    print('Error executing command: $e');
  }
}
