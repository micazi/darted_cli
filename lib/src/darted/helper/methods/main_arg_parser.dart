import '../../../../console_helper.dart';
import '../../../../darted_cli.dart';
import '../../constants/print_constants.dart';

Future<
    (
      Map<String, (Map<String, dynamic> arguments, Map<String, bool> flags)>?,
      String? errorCode
    )> parseMainArgImpl({
  required List<DartedCommand> commandsTree,
  required Map<String,
          (Map<String, dynamic> arguments, Map<String, bool> flags)>
      callStack,
  String Function(String command, String? suggestedCommand)?
      customCommandInvalidError,
}) async {
  String? exitError;
  Map<String, (Map<String, dynamic> arguments, Map<String, bool> flags)>
      updatedCallStack = {...callStack};
  Map<String, String> commandsWithMainArgs = {};

  // Loop through the commandsTree to check for ones with a 'Main' argument
  void processCommands(List<DartedCommand> commands) {
    for (var commandEntry in commands) {
      if (commandEntry.arguments != null &&
          commandEntry.arguments!
              .where((arg) => (arg?.isMainReq) ?? false)
              .isNotEmpty) {
        // Has at least one main Arg.
        List<DartedArgument> mainArgs = commandEntry.arguments!
            .where((arg) => (arg?.isMainReq) ?? false)
            .where((a) => a != null)
            .map((aa) => aa as DartedArgument)
            .toList();

        if (mainArgs.length > 1) {
          exitError =
              "$startPrint\n|\n| ${'Error:'.withColor(ConsoleColor.red)} Command ${commandEntry.name.withColor(ConsoleColor.green)} has too many 'Main' arguments; Only ONE is allowed.\n|\n$endPrint\n";
          break;
        } else {
          if (commandEntry.subCommands != null &&
              commandEntry.subCommands!.isNotEmpty) {
            exitError =
                "$startPrint\n|\n| ${'Error:'.withColor(ConsoleColor.red)} Command ${commandEntry.name.withColor(ConsoleColor.green)} can't have both sub-commands and positional arguments.\n|\n$endPrint\n";
            break;
          } else {
            commandsWithMainArgs = {
              ...commandsWithMainArgs,
              ...Map.fromEntries(
                  [MapEntry(commandEntry.name, mainArgs.first.name)])
            };
          }
        }
      }

      // Recursively process subcommands
      if (commandEntry.subCommands != null &&
          commandEntry.subCommands!.isNotEmpty) {
        processCommands(commandEntry.subCommands!);
      }
    }
  }

  // Initial Call
  processCommands(commandsTree);

  if (exitError != null) return (null, exitError);

  // Work through the call stack and check if there is a 'Main' argument supplied.
  for (var commandEntry
      in List<MapEntry<String, (Map<String, dynamic>, Map<String, bool>)>>.from(
          callStack.entries)) {
    int thisIndex =
        callStack.entries.toList().indexWhere((e) => e.key == commandEntry.key);
    int nextIndex = thisIndex + 1;
    if (commandsWithMainArgs.containsKey(commandEntry.key)) {
      // This command needs to have a main Arg.
      if (callStack.entries.length > 1 &&
          nextIndex < callStack.entries.length) {
        // There's something after this command and it should be parsed as an arg
        String theArgName = commandsWithMainArgs[commandEntry.key]!;
        String theArgValue = callStack.entries.toList()[nextIndex].key;
        Map<String, dynamic>? argsOfNextCommand = callStack[theArgValue]?.$1;
        Map<String, dynamic>? flagsOfNextCommand = callStack[theArgValue]?.$2;
        Map<String, dynamic> newArgsMap = {
          ...Map.fromEntries([MapEntry(theArgName, theArgValue)]),
          ...callStack[commandEntry.key]?.$1 ?? {},
          ...argsOfNextCommand ?? {},
        };
        Map<String, bool> newFlagsMap = {
          ...callStack[commandEntry.key]?.$2 ?? {},
          ...flagsOfNextCommand ?? {},
        };
        updatedCallStack.remove(theArgValue);
        updatedCallStack[commandEntry.key] = (
          newArgsMap,
          newFlagsMap,
        );
      } else {
        if (commandEntry.value.$2.isNotEmpty &&
                commandEntry.value.$2.keys.contains('help') ||
            commandEntry.value.$2.keys.contains('version')) {
          // Help OR Version flagged
        } else {
          // The arg is missing...
          // Is now catched within the callstack validation.
        }
      }
    }
  }
  //
  return (updatedCallStack, null);
}
