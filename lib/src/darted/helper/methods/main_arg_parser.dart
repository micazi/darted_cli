import '../../../../console_helper.dart';
import '../../../../darted_cli.dart';
import '../../constants/print_constants.dart';

Future<Map<String, (Map<String, dynamic> arguments, Map<String, bool> flags)>> parseMainArgImpl({
  required List<DartedCommand> commandsTree,
  required Map<String, (Map<String, dynamic> arguments, Map<String, bool> flags)> callStack,
  String Function(String command)? customCommandInvalidError,
}) async {
  Map<String, (Map<String, dynamic> arguments, Map<String, bool> flags)> updatedCallStack = callStack;
  Map<String, String> commandsWithMainArgs = {};

  // Loop through the commandsTree to check for ones with a 'Main' argument
  for (var commandEntry in commandsTree) {
    if (commandEntry.arguments != null && commandEntry.arguments!.where((arg) => (arg?.isMainReq) ?? false).isNotEmpty) {
      // Has at least one main Arg.
      List<DartedArgument> mainArgs = commandEntry.arguments!.where((arg) => (arg?.isMainReq) ?? false).where((a) => a != null).map((aa) => aa as DartedArgument).toList();
      if (mainArgs.length > 1) {
        // INVALID: More than one argument specified.
        ConsoleHelper.write(
          "$startPrint\n|\n| ${'Error:'.withColor(ConsoleColor.red)} Command ${commandEntry.name.withColor(ConsoleColor.green)} has too many 'Main' arguments; Only ONE is allowed.\n|\n$endPrint\n",
        );
      } else {
        commandsWithMainArgs.addEntries([MapEntry(commandEntry.name, mainArgs.first.name)]);
      }
    }
  }

  // Work through the call stack and check if there is a 'Main' argument supplied.
  for (var commandEntry in List<MapEntry<String, (Map<String, dynamic>, Map<String, bool>)>>.from(callStack.entries)) {
    int thisIndex = callStack.entries.toList().indexOf(commandEntry);
    int nextIndex = thisIndex + 1;
    if (commandsWithMainArgs.containsKey(commandEntry.key)) {
      // This command needs to have a main Arg.
      if (callStack.entries.length > 1 && nextIndex < callStack.entries.length) {
        // There's something after this command and it should be parsed as an arg
        String theArgName = commandsWithMainArgs[commandEntry.key]!;
        String theArgValue = callStack.keys.toList()[nextIndex + 1];
        Map<String, dynamic>? argsOfNextCommand = callStack[theArgValue]?.$1;
        Map<String, dynamic> newArgsMap = {
          ...Map.fromEntries([MapEntry(theArgName, theArgValue)]),
          ...callStack[commandEntry.key]?.$1 ?? {},
          ...argsOfNextCommand ?? {},
        };
        updatedCallStack.remove(theArgValue);
        updatedCallStack[commandEntry.key] = (
          newArgsMap,
          callStack[commandEntry.key]?.$2 ?? {},
        );
      } else {
        // The arg is missing...
        if (commandEntry.value.$2.isNotEmpty && commandEntry.value.$2.keys.contains('help') || commandEntry.value.$2.keys.contains('version')) {
          // Help OR Version flagged
        } else {
          ConsoleHelper.write(
            customCommandInvalidError?.call(commandEntry.key) ??
                "$startPrint\n|\n| ${'Error:'.withColor(ConsoleColor.red)} Command ${commandEntry.key.toString().withColor(ConsoleColor.blue)} is invalid.\n|\n$endPrint\n",
          );
        }
      }
    }
  }
  //
  return updatedCallStack;
}
