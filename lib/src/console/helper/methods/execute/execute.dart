import 'dart:io';
import 'parse_args.dart';

Future<dynamic> executeCommandImpl(String commandWithArgs) async {
  try {
    // Parse the command and arguments
    final commandArgs = parseArguments(commandWithArgs);

    // Run the command
    final result = await Process.run(commandArgs[0], commandArgs.sublist(1));

    // Handle the result (check for errors and print output)
    if (result.exitCode != 0 || result.stderr.isNotEmpty) {
      throw result.stderr.toString();
    }

    // Return the output if it exists
    if (result.stdout.isNotEmpty) {
      return result.stdout;
    }
  } catch (e) {
    throw e.toString();
  }
}
