import 'console.helper.dart';

class CallbackHelper {
  final List<String> commandStack;
  final Map<String, String> arguments;
  final Map<String, bool> flags;
  final ConsoleHelper console;

  // Error messages
  String noCommandError = "Command not recognized. Use --help for available commands.";
  String noArgumentMatchError = "No matching arguments found. Check --help for available arguments.";
  String noFlagMatchError = "Invalid flag provided. Use --help to see valid flags.";

  // Default Help and version responses
  String helpResponse = "Usage: [command] --help to see available commands and options.";
  String versionResponse = "darted_CLI version 1.0.0";

  CallbackHelper({
    required this.commandStack,
    required this.arguments,
    required this.flags,
    required this.console,
  });

  // Setters for error and response messages
  void setNoCommandError(String message) {
    noCommandError = message;
  }

  void setNoArgumentMatchError(String message) {
    noArgumentMatchError = message;
  }

  void setNoFlagMatchError(String message) {
    noFlagMatchError = message;
  }

  void setHelpResponse(String message) {
    helpResponse = message;
  }

  void setVersionResponse(String message) {
    versionResponse = message;
  }

  // Getters for help and version responses
  String getHelpResponse() => helpResponse;
  String getVersionResponse() => versionResponse;
}
