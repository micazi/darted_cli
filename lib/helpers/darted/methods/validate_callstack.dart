import 'package:darted_cli/darted_cli.dart';

import '../../../models/models.exports.dart';
import '../../console/console.helper.dart';

bool validateCallStackImpl(
  List<DartedCommand> commandsTree,
  Map<String, (Map<String, dynamic> arguments, Map<String, bool> flags)> callStack,
  //
  {
  String Function(String command)? customCommandInvalidError,
  String Function(String command, Map<String, dynamic> argument)? customArgumentInvalidError,
  String Function(String command, Map<String, dynamic> argument, List<String> acceptedOptions)? customArgumentOptionsInvalidError,
  String Function(String command, Map<String, bool> flag)? customFlagInvalidError,
  String Function(String command, Map<String, bool> flag)? customFlagNegatedError,
}) {
  DartedCommand? currentNode;
  List<DartedCommand> availableCommands = commandsTree;

  // Loop through the callStack entries.
  for (var callStackEntry in callStack.entries) {
    String currentCommandName = callStackEntry.key;
    Map<String, dynamic> currentCommandArguments = callStackEntry.value.$1;
    Map<String, bool> currentCommandFlags = callStackEntry.value.$2;

    // Find the command in the available commands of the current level.
    currentNode = availableCommands.where((cmd) => cmd.name == currentCommandName).firstOrNull;

    // The command hierarchy is invalid.
    if (currentNode == null) {
      ConsoleHelper.write(customCommandInvalidError?.call(currentCommandName) ?? "Error: Command ${currentCommandName.withColor(ConsoleColor.blue)} is invalid.\n|-------", newLine: true);
      return false;
    }

    // Validate the command's arguments.
    for (var arg in currentCommandArguments.keys) {
      DartedArgument? argumentNode = currentNode.arguments?.where((a) => (a?.name == arg || a?.abbreviation == arg)).firstOrNull;
      bool argumentExists = argumentNode != null;

      // The argument supplied is invalid.
      if (!argumentExists) {
        ConsoleHelper.write(
          customArgumentInvalidError?.call(currentCommandName, Map.fromEntries([MapEntry(arg, currentCommandArguments[arg])])) ??
              "|-------\n| ${'Error:'.withColor(ConsoleColor.red)} Argument ${arg.withColor(ConsoleColor.green)} is invalid for the ${currentCommandName.withColor(ConsoleColor.blue)} command.\n|-------",
        );
        return false;
      }

      bool isMultiOption = argumentNode.isMultiOption;
      if (isMultiOption) {
        List<String> acceptedOptions = argumentNode.acceptedMultiOptionValues?.split(argumentNode.optionsSeparator ?? '/') ?? [];
        List<String> suppliedOptions = currentCommandArguments[arg].toString().split(argumentNode.optionsSeparator ?? '/');

        if (!acceptedOptions.containsAll(suppliedOptions)) {
          ConsoleHelper.write(
            customArgumentOptionsInvalidError?.call(currentCommandName, Map.fromEntries([MapEntry(arg, currentCommandArguments[arg])]), acceptedOptions) ??
                "|-------\n| ${'Error:'.withColor(ConsoleColor.red)} Argument ${arg.withColor(ConsoleColor.green)} of the ${currentCommandName.withColor(ConsoleColor.blue)} command has invlid options. Supperted (${acceptedOptions.join(',')}) and supplied (${suppliedOptions.join(',')}).\n|-------",
          );
          return false;
        }
      }
    }

    // Validate the command's flags
    for (var flag in currentCommandFlags.keys) {
      DartedFlag? flagNode = currentNode.flags?.where((f) => (f.name == flag || f.abbreviation == flag)).firstOrNull;
      bool flagExists = flagNode != null;
      bool canBeNegated = flagNode?.canBeNegated ?? false;
      bool isFlagNegated = !(currentCommandFlags[flag] ?? true);
      //
      if (!flagExists) {
        ConsoleHelper.write(
          customFlagInvalidError?.call(currentCommandName, Map.fromEntries([MapEntry(flag, (currentCommandFlags[flag] ?? false))])) ??
              "|-------\n| ${'Error:'.withColor(ConsoleColor.red)} Flag ${flag.withColor(ConsoleColor.green)} is invalid for the ${currentCommandName.withColor(ConsoleColor.blue)} command.\n|-------",
        );
        return false;
      }

      if (!canBeNegated && isFlagNegated) {
        ConsoleHelper.write(
          customFlagNegatedError?.call(currentCommandName, Map.fromEntries([MapEntry(flag, (currentCommandFlags[flag] ?? false))])) ??
              "|-------\n| ${'Error:'.withColor(ConsoleColor.red)} Flag ${flag.withColor(ConsoleColor.green)} of the ${currentCommandName.withColor(ConsoleColor.blue)} command doesn't support negation.\n|-------",
        );
        return false;
      }
    }

    // Move to the next level of the tree
    availableCommands = currentNode.subCommands ?? [];
  }
  return true;
}

extension ListExtension<E> on List<E> {
  bool containsAll(List<E> otherList) {
    List<bool> checks = [];
    //
    for (E thisElement in otherList) {
      checks.add(contains(thisElement));
    }
    return !checks.contains(false);
  }
}
