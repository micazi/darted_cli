import 'package:darted_cli/darted_cli.dart';
import 'package:darted_cli/helpers/darted/prints/darted_main.dart';
import 'package:darted_cli/helpers/darted/prints/stable_points.dart';
import 'package:darted_cli/modules/ascii-art/ascii_art.module.dart';

void main(List<String> input) async => await dartedEntry(
      input: input,
      customEntryHelper: (tree) async {
        String asciiArt = await AsciiArtModule.textToAscii('DARTED');
        return startPrint + asciiArt + endPrint;
      },
      // Available commands, arguments, and flags to process.
      commandsTree: [
        DartedCommand(
          /// Needs to be the same as the package name.
          name: 'darted_cli',
          helperDescription: "The helper messaage of the main entry",
          callback: (arguments, flags) => ConsoleHelper.write(dartedMainPrint),
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
            DartedCommand(name: 'Some_other', callback: (arguments, flags) {}, helperDescription: "This will give me a another command instance!"),
            DartedCommand(name: 'Another_One', callback: (arguments, flags) {}, helperDescription: "Some of the data here")
          ],
        ),
      ],
    );
