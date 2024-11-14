import 'models/models.exports.dart';
//
export 'helpers/helpers.exports.dart';
export 'models/models.exports.dart';

import 'dart:async';

Future<void> dartedEntry({
  required List<DartedCommand> commandsTree,
  required List<String> args,
}) async {
  // Parse commands, arguments, and flags
  final parsedArgs = parseArgs(args);
  final commandStack = List<String>.from(parsedArgs['commands']);
  final inputArgs = parsedArgs['arguments'] as Map<String, String?>;
  final inputFlags = parsedArgs['flags'] as List<String>;

  // Find the matching command based on hierarchy
  final matchedCommand = findMatchingCommand(commandsTree, commandStack);
  if (matchedCommand == null) {
    print('Error: Command path not found or incorrect hierarchy');
    return;
  }

  // Validate and map arguments and flags
  final argValidation = validateAndMapArguments(matchedCommand, inputArgs);
  if (!argValidation['isValid']) {
    print('Error: ${argValidation['errorMessage']}');
    return;
  }

  final flagMapping = mapFlags(matchedCommand, inputFlags);

  // Execute the command callback with validated arguments and flags
  await matchedCommand.callback(argValidation['mappedArgs'] as Map<String, String?>, flagMapping);
}

DartedCommand? findMatchingCommand(List<DartedCommand> commandsTree, List<String> commandStack) {
  DartedCommand? currentCommand;
  for (final commandName in commandStack) {
    final command = (currentCommand?.subCommands ?? commandsTree).firstWhere(
      (cmd) => cmd.name == commandName,
      orElse: () => throw Exception("Command '$commandName' not found in hierarchy."),
    );
    currentCommand = command;
  }
  return currentCommand;
}

Map<String, dynamic> validateAndMapArguments(DartedCommand command, Map<String, String?> inputArgs) {
  final mappedArgs = <String, String?>{};
  for (final argument in command.arguments ?? []) {
    final argValue = inputArgs[argument!.abbreviation] ?? inputArgs[argument.name] ?? argument.defaultValue;

    if (argValue != null) {
      if (argument.isMultiOption && argument.acceptedMultiOptionValues != null) {
        final acceptedValues = argument.acceptedMultiOptionValues!.split(argument.optionsSeparator ?? '/');
        final userValues = argValue.split(argument.optionsSeparator ?? '/');
        if (userValues.every((val) => acceptedValues.contains(val))) {
          mappedArgs[argument.name] = argValue;
        } else {
          return {'isValid': false, 'errorMessage': 'Invalid values for argument: ${argument.name}'};
        }
      } else {
        mappedArgs[argument.name] = argValue;
      }
    } else if (argValue == null && argument.defaultValue == null) {
      return {'isValid': false, 'errorMessage': 'Missing required argument: ${argument.name}'};
    }
  }
  return {'isValid': true, 'mappedArgs': mappedArgs};
}

Map<String, bool> mapFlags(DartedCommand command, List<String> inputFlags) {
  final mappedFlags = <String, bool>{};
  for (final flag in command.flags ?? []) {
    final flagName = flag.name;
    final isNegated = flag.canBeNegated && inputFlags.contains('no-$flagName');
    mappedFlags[flagName] = isNegated ? false : inputFlags.contains(flagName) || flag.appliedByDefault;
  }
  return mappedFlags;
}

Map<String, dynamic> parseArgs(List<String> args) {
  final commands = <String>[];
  final arguments = <String, String?>{};
  final flags = <String>[];

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];

    if (arg.startsWith('--no-')) {
      // Negated flag
      flags.add(arg.substring(5)); // Add negated flag name without "no-"
    } else if (arg.startsWith('--')) {
      // Long form argument or flag
      final argumentName = arg.substring(2);
      if (i + 1 < args.length && !args[i + 1].startsWith('-')) {
        // It's an argument with a value
        arguments[argumentName] = args[++i];
      } else {
        // It's a flag with no value
        flags.add(argumentName);
      }
    } else if (arg.startsWith('-') && arg.length == 2) {
      // Short form argument or flag
      final shortName = arg.substring(1);
      if (i + 1 < args.length && !args[i + 1].startsWith('-')) {
        // It's an argument with a value
        arguments[shortName] = args[++i];
      } else {
        // It's a flag
        flags.add(shortName);
      }
    } else {
      // Treat as command if no prefix
      commands.add(arg);
    }
  }
  return {'commands': commands, 'arguments': arguments, 'flags': flags};
}
