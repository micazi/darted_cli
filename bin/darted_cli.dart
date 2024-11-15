import 'package:darted_cli/darted_cli.dart';

void main(List<String> input) async => await dartedEntry(
      input: input,
      // Available commands, arguments, and flags to process.
      commandsTree: [
        DartedCommand(
          /// Needs to be the same as the package name.
          name: 'darted_cli',
          helperDescription: "This is the main tool.",
          callback: (arguments, flags) => ConsoleHelper.write('${'This command is ${'darted_cli'.withColor(ConsoleColor.green)}'} I have the arguments: $arguments, and the flags: $flags'),
          flags: [
            /// Easy helpers for standard flags.
            DartedFlag.version,
            DartedFlag.help,
          ],
          arguments: [
            DartedArgument(name: 'someData', abbreviation: 's', defaultValue: 'defaultData', isMultiOption: false),
          ],
          subCommands: [
            DartedCommand(
              name: 'create',
              helperDescription: "This will give me a create!",
              callback: (arguments, flags) => ConsoleHelper.write('${'This command is ' 'create'.withColor(ConsoleColor.green)} I have the arguments: $arguments, and the flags: $flags'),
              arguments: [
                DartedArgument(name: 'name', abbreviation: 'n', defaultValue: 'new_flutter_project', isMultiOption: false),
                DartedArgument(name: 'platforms', abbreviation: 'p', acceptedMultiOptionValues: 'android,ios,web', isMultiOption: true, optionsSeparator: ','),
              ],
              flags: [
                DartedFlag.help,
                DartedFlag(name: 'package', abbreviation: 'pa', canBeNegated: false, appliedByDefault: true),
                DartedFlag(name: 'solo', abbreviation: 's', canBeNegated: true, appliedByDefault: true),
              ],
            ),
            DartedCommand(name: 'Some Other command', callback: (arguments, flags) {}, helperDescription: "This will give me a another command instance!"),
            DartedCommand(name: 'One more command', callback: (arguments, flags) {}, helperDescription: "Some of the data here")
          ],
        ),
      ],
    );
