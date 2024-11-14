import 'package:darted_cli/darted_cli.dart';

void main(List<String> args) async => await dartedEntry(
      args: args,
      // Available commands, arguments, and flags to process.
      commandsTree: [
        DartedCommand(
          /// Needs to be the same as the package name.
          name: 'darted_cli',
          callback: (arguments, flags) => ConsoleHelper.write('${'This command is ${'darted_cli'.withColor(ConsoleColor.green)}'} I have the arguments: $arguments, and the flags: $flags'),
          flags: [
            /// Easy helpers for standard flags.
            DartedFlag.version(),
            DartedFlag.help(),
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
              flags: [
                DartedFlag.help(),
              ],
            ),
          ],
        ),
      ],
    );
