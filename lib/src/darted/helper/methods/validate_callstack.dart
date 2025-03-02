import '../../../console/helper/console.helper.dart';
import '../../../console/models/console_models.exports.dart';
import '../../../infrastructure/list.extension.dart';
import '../../../io/helper/io.helper.dart';
import '../../../modules/ascii-art/ascii_art.module.dart';
import '../../../modules/yaml/yaml.module.dart';
import '../../constants/print_constants.dart';
import '../../models/darted_models.exports.dart';
import 'find_command_closest_match.dart';

Future<(bool isValid, String? error)> validateCallStackImpl(
  List<DartedCommand> commandsTree,
  Map<String, (Map<String, dynamic> arguments, Map<String, bool> flags)> cs,
  //
  {
  String? customEntryHelper,
  String? customVersionResponse,
  String Function(String command, String? suggestedCommand)?
      customCommandInvalidError,
  String Function(String command, Map<String, dynamic> argument,
          String? suggestedArgument)?
      customArgumentInvalidError,
  String Function(String command, Map<String, dynamic> argument,
          List<String> acceptedOptions)?
      customArgumentOptionsInvalidError,
  String Function(String command, Map<String, bool> flag)?
      customFlagInvalidError,
  String Function(String command, Map<String, bool> flag)?
      customFlagNegatedError,
}) async {
  DartedCommand? currentNode;
  List<DartedCommand> availableCommands = commandsTree;
  Map<String, (Map<String, dynamic> arguments, Map<String, bool> flags)>
      callStack = cs;

  // check if it's the version call
  if (callStack.length == 1 && callStack.keys.first == 'version') {
    return (false, (customVersionResponse ?? await defaultVersionMessage()));
  }

  // Check if there's no commands in the stack, return the entry helper.
  if (callStack.isEmpty) {
    // Entry Helper
    return (false, customEntryHelper ?? await defaultEntryHelper(commandsTree));
  }

  // Loop through the callStack entries.
  for (var callStackEntry in callStack.entries) {
    String currentCommandName = callStackEntry.key;
    Map<String, dynamic> currentCommandArguments = callStackEntry.value.$1;
    Map<String, bool> currentCommandFlags = callStackEntry.value.$2;

    // Find the command in the available commands of the current level.
    currentNode = availableCommands
        .where(
            (cmd) => cmd.name.toLowerCase() == currentCommandName.toLowerCase())
        .firstOrNull;

    // The command hierarchy is invalid.
    if (currentNode == null) {
      String? findCloseMatch = getClosestMatch(
          currentCommandName, availableCommands.map((cc) => cc.name).toList());
      return (
        false,
        customCommandInvalidError?.call(currentCommandName, findCloseMatch) ??
            "$startPrint\n|\n| ${'Error:'.withColor(ConsoleColor.red)} Command ${currentCommandName.withColor(ConsoleColor.blue)} is invalid.\n|\n${findCloseMatch != null ? '| Could you possibly mean ${findCloseMatch.withColor(ConsoleColor.green)}?\n' : ''}$endPrint\n"
      );
    }

    // Validate the command's main argument is supplied.
    DartedArgument? currentCommandMainArg = currentNode.arguments
        ?.where((a) => (a?.isMainReq ?? false))
        .firstOrNull;
    if (currentCommandMainArg != null) {
      // This command has a main Arg.
      if (!currentCommandArguments.keys.contains(currentCommandMainArg.name) &&
          !currentCommandArguments.keys
              .contains(currentCommandMainArg.abbreviation)) {
        // No main argument supplied
        return (
          false,
          customArgumentInvalidError?.call(
                  currentCommandName,
                  Map.fromEntries([MapEntry(currentCommandMainArg.name, null)]),
                  null) ??
              "$startPrint\n|\n| ${'Error:'.withColor(ConsoleColor.red)} Positional Argument ${currentCommandMainArg.name.withColor(ConsoleColor.green)} is required for the ${currentCommandName.withColor(ConsoleColor.blue)} command.\n|\n$endPrint\n",
        );
      }
    }

    // Validate the command's arguments.
    for (var arg in currentCommandArguments.keys) {
      DartedArgument? argumentNode = currentNode.arguments
          ?.where((a) => (a?.name == arg || a?.abbreviation == arg))
          .firstOrNull;
      bool argumentExists = argumentNode != null;

      // The argument supplied is invalid.
      if (!argumentExists) {
        String? findCloseMatch;
        if (currentNode.arguments != null) {
          findCloseMatch = getClosestMatch(
              arg, currentNode.arguments!.map((arg) => arg!.name).toList());
        }
        return (
          false,
          customArgumentInvalidError?.call(
                  currentCommandName,
                  Map.fromEntries(
                      [MapEntry(arg, currentCommandArguments[arg])]),
                  findCloseMatch) ??
              "$startPrint\n|\n| ${'Error:'.withColor(ConsoleColor.red)} Argument ${arg.withColor(ConsoleColor.green)} is invalid for the ${currentCommandName.withColor(ConsoleColor.blue)} command.\n|\n${findCloseMatch != null ? '| Could you possibly mean ${findCloseMatch.withColor(ConsoleColor.green)}?\n' : ''}$endPrint\n"
        );
      }

      bool isMultiOption = argumentNode.isMultiOption;
      if (isMultiOption) {
        List<String> acceptedOptions = argumentNode.acceptedMultiOptionValues
                ?.split(argumentNode.optionsSeparator ?? '/') ??
            [];
        List<String> suppliedOptions = currentCommandArguments[arg]
            .toString()
            .split(argumentNode.optionsSeparator ?? '/');

        if (!acceptedOptions.containsAll(suppliedOptions)) {
          return (
            false,
            customArgumentOptionsInvalidError?.call(
                    currentCommandName,
                    Map.fromEntries(
                        [MapEntry(arg, currentCommandArguments[arg])]),
                    acceptedOptions) ??
                "$startPrint\n|\n| ${'Error:'.withColor(ConsoleColor.red)} Argument ${arg.withColor(ConsoleColor.green)} of the ${currentCommandName.withColor(ConsoleColor.blue)} command has invlid options. Supperted (${acceptedOptions.join(',')}) and supplied (${suppliedOptions.join(',')}).\n|\n$endPrint\n"
          );
        }
      }
    }

    // Validate the command's flags
    for (var flag in currentCommandFlags.keys) {
      DartedFlag? flagNode = currentNode.flags
          ?.where((f) => (f.name == flag || f.abbreviation == flag))
          .firstOrNull;
      bool flagExists = flagNode != null;
      bool canBeNegated = flagNode?.canBeNegated ?? false;
      bool isFlagNegated = !(currentCommandFlags[flag] ?? true);
      //
      if (!flagExists) {
        return (
          false,
          customFlagInvalidError?.call(
                  currentCommandName,
                  Map.fromEntries([
                    MapEntry(flag, (currentCommandFlags[flag] ?? false))
                  ])) ??
              "$startPrint\n|\n| ${'Error:'.withColor(ConsoleColor.red)} Flag ${flag.withColor(ConsoleColor.green)} is invalid for the ${currentCommandName.withColor(ConsoleColor.blue)} command.\n|\n$endPrint\n"
        );
      }

      if (!canBeNegated && isFlagNegated) {
        return (
          false,
          customFlagNegatedError?.call(
                  currentCommandName,
                  Map.fromEntries([
                    MapEntry(flag, (currentCommandFlags[flag] ?? false))
                  ])) ??
              "$startPrint\n|\n| ${'Error:'.withColor(ConsoleColor.red)} Flag ${flag.withColor(ConsoleColor.green)} of the ${currentCommandName.withColor(ConsoleColor.blue)} command doesn't support negation.\n|\n$endPrint\n"
        );
      }
    }

    // Move to the next level of the tree
    availableCommands = currentNode.subCommands ?? [];
  }
  return (true, null);
}

Future<String> defaultEntryHelper(List<DartedCommand> commandsTree) async {
  String pubspecPath = await IOHelper.file
      .find(IOHelper.directory.getCurrent(), 'pubspec.yaml')
      .then((v) => v.first);
  YamlMap pubspecContent = await YamlModule.load(pubspecPath);
  String packageName = pubspecContent['name'];
  String packageDescription = pubspecContent['description'].toString().trim();
  //
  bool hasSubCommands = commandsTree.isNotEmpty;
  Map<String, String> subCommandsHelpersMap = Map.fromEntries(commandsTree
      .map((s) => MapEntry(s.name, s.helperDescription ?? 'No Helper Message.'))
      .toList());
  String? justifiedCommands = hasSubCommands && subCommandsHelpersMap.isNotEmpty
      ? ConsoleHelper.justifyMap(subCommandsHelpersMap,
              gapSeparatorSize: 8, preKey: '| ')
          .reduce((a, b) => "$a\n$b")
      : null;
  //
  String packageArt = await AsciiArtModule.textToAscii(packageName,
      beforeEachLine: "|  ", color: ConsoleColor.green);
  String usage = "Usage: $packageName sub-command [arguments...] (flags...)";
  return """
$startPrint
$packageArt
| $packageDescription
| 
| $usage
| 
$justifiedCommands
| 
| 
$endPrint\n
""";
}
