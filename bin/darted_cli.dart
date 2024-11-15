import 'package:darted_cli/darted_cli.dart';
import 'package:darted_cli/helpers/darted/methods/validate_arguments.dart';
import 'package:darted_cli/helpers/darted/methods/validate_commands.dart';

// void main(List<String> args) async => await dartedEntry(
//       args: args,
//       // Available commands, arguments, and flags to process.
List<DartedCommand> commandsTree = [
  DartedCommand(
    /// Needs to be the same as the package name.
    name: 'darted_cli',
    callback: (arguments, flags) => ConsoleHelper.write('${'This command is ${'darted_cli'.withColor(ConsoleColor.green)}'} I have the arguments: $arguments, and the flags: $flags'),
    flags: [
      /// Easy helpers for standard flags.
      DartedFlag.version(),
    ],
    arguments: [
      DartedArgument(name: 'someData', abbreviation: 's', defaultValue: 'defaultData', isMultiOption: false),
    ],
    subCommands: [
      DartedCommand(
        name: 'create',
        callback: (arguments, flags) => ConsoleHelper.write('${'This command is ' 'create'.withColor(ConsoleColor.green)} I have the arguments: $arguments, and the flags: $flags'),
        arguments: [
          DartedArgument(name: 'name', abbreviation: 'n', defaultValue: 'new_flutter_project', isMultiOption: false),
          DartedArgument(name: 'platforms', abbreviation: 'p', acceptedMultiOptionValues: 'android/ios/web', isMultiOption: true, optionsSeparator: '/'),
        ],
        flags: [],
      ),
    ],
  ),
];

void main(List<String> args) async {
  Map<String, dynamic> parsedArgs = parseArgs(args);
  ConsoleHelper.write("All parsed args: $parsedArgs", newLine: true);
  //
  List<String> parsedCommands = parsedArgs['commands'];
  ConsoleHelper.write("All parsed commands: $parsedCommands", newLine: true);
  //
  Map<String, dynamic> parsedArguments = parsedArgs['arguments'];
  ConsoleHelper.write("All parsed arguments: $parsedArguments", newLine: true);
  //
  List<String> parsedFlags = parsedArgs['flags'];
  ConsoleHelper.write("All parsed flags: $parsedFlags", newLine: true);
  //
  Map<String, (Map<String, dynamic> arguments, List<String> flags)> callStack = Map.fromEntries(parsedCommands.map((comm) {
    //
    int commIndex = args.indexOf(comm);
    ConsoleHelper.write("Current command is $comm with index: $commIndex", newLine: true);
    String nextCommand = parsedCommands[commIndex];
    int nextCommIndex = args.indexOf(nextCommand);
    ConsoleHelper.write("Next command is $nextCommand with index: $nextCommIndex", newLine: true);
    // ConsoleHelper.write("next command: $nextCommand", newLine: true);
    List<String> commData = args.sublist(commIndex + 1, nextCommIndex);
    Map<String, dynamic> comArgs = Map.fromEntries(parsedArguments.entries.where((s) => (commData.contains("--${s.key}") || commData.contains("-${s.key}")) && commData.contains(s.value)).toList());
    //
    ConsoleHelper.write("Command is $comm, Command arguments is: $comArgs", newLine: true);
    return MapEntry('', ({}, []));
    // return MapEntry(
    //   comm,
    // );
  }));
  // String lastCommand = parsedCommands.last;
  // int lastCommandIndex = args.indexOf(lastCommand);
  // List<String> lastCommandData = args.sublist(lastCommandIndex + 1);
  // ConsoleHelper.write("The last command is: $lastCommand");
  // ConsoleHelper.write("The data of the last command is: $lastCommandData", newLine: true);
  // Map<String, dynamic> lastCommandArguments =
  //     Map.fromEntries(parsedArguments.entries.where((s) => (lastCommandData.contains("--${s.key}") || lastCommandData.contains("-${s.key}")) && lastCommandData.contains(s.value)).toList());
  // List<String> lastCommandFlags = parsedFlags.where((f) => (lastCommandData.contains("--$f") || lastCommandData.contains("--no-$f") || lastCommandData.contains("-$f"))).toList();
  // Map<String, bool> lastCommandFlagsMapped = Map.fromEntries(lastCommandFlags.map((f) => MapEntry(f, !lastCommandData.contains('--no-$f'))));
  //
  // ConsoleHelper.write("The arguments of the last command is: $lastCommandArguments", newLine: true);
  // ConsoleHelper.write("The flags of the last command is: $lastCommandFlags", newLine: true);
  // ConsoleHelper.write("The mapped flags of the last command is: $lastCommandFlagsMapped", newLine: true);

// 1. Validate the command hierarchy
  // DartedCommand? matchedCommand = validateCommandHierarchy(commandsTree, parsedCommands);
  // if (matchedCommand == null) {
  //   ConsoleHelper.write("Error: Command hierarchy is invalid or not found in commands tree.", newLine: true);
  //   return;
  // }

  // 2. Validate the existence of the arguments for the last command
  // Map<String, dynamic>? validatedArguments = validatedTheArguments(matchedCommand, lastCommandArguments);
  // if (validatedArguments == null) {
  //   ConsoleHelper.write("Error: Some arguments for the last command are invalid or missing.", newLine: true);
  //   return;
  // }
  // ConsoleHelper.write("The good validated arguments are: $validatedArguments", newLine: true);
  // if () {
  // }

  // 3. Validate the existence of the flags for the last command
  // bool flagsValid = validateFlags(matchedCommand, lastCommandFlagsMapped);
  // if (!flagsValid) {
  //   ConsoleHelper.write("Error: Some flags for the last command are invalid or missing.", newLine: true);
  //   return;
  // }

  // If all validations pass, proceed with the command callback or logic
  // await matchedCommand.callback(lastCommandArguments, lastCommandFlagsMapped);
}

/// Validates that all flags for a command exist and are allowed.
bool validateFlags(DartedCommand command, Map<String, bool> inputFlags) {
  for (final flagEntry in inputFlags.entries) {
    final flagName = flagEntry.key;
    final flag = (command.flags ?? [])
        .where(
          (f) => f.name == flagName,
          // orElse: () => null,
        )
        .firstOrNull;
    if (flag == null) {
      ConsoleHelper.write("Error: Flag '$flagName' is not valid for the command '${command.name}'.", newLine: true);
      return false;
    }
  }
  return true;
}
