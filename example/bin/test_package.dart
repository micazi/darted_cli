import 'package:darted_cli/ascii_art_module.dart';
import 'package:darted_cli/console_helper.dart';
import 'package:darted_cli/darted_cli.dart';

import '../lib/main.dart';

final List<DartedCommand> commandsTree = [
  DartedCommand(
    // Give the command a name..
    name: 'create',
    // Give it a helper description.. (optional)
    helperDescription: "This will create something..",
    // Give it the allowed arguments..
    arguments: [
      // --name [something] & -n [something] are now allowed and will be availbale in your callback if the user input it!
      // If the user didn't input the argument, you will get the default value..
      DartedArgument(
          name: 'name',
          abbreviation: 'n',
          defaultValue: 'new_flutter_project',
          isMultiOption: false),
      // You also have the option to allow an argument to have multible options, with input validation based on the accepted options YOU enter!
      DartedArgument(
          name: 'platforms',
          abbreviation: 'p',
          acceptedMultiOptionValues: 'android,ios,web',
          isMultiOption: true,
          optionsSeparator: ','),
    ],
    // Now, give it the flags allowed for this specific command, You can allow it to be negated too! (--no-flag)
    flags: [
      // Provided flag template for the --help/-h flag, it's automatically captured and you can customize it's output!
      DartedFlag.help,
      // Oh, and you can also allow flags to be applied by default even if they are not passed in..
      DartedFlag(
          name: 'package',
          abbreviation: 'pa',
          canBeNegated: false,
          appliedByDefault: true),
      DartedFlag(
          name: 'solo',
          abbreviation: 's',
          canBeNegated: true,
          appliedByDefault: false),
    ],
    // And finally, give your command a callback based on the arguments and flags you get. It can't get any easier!
    callback: (arguments, flags) => ConsoleHelper.write(
      '${'This command is ' 'create'.withColor(ConsoleColor.green)} I have the arguments: $arguments, and the flags: $flags',
    ),
    subCommands: [
      DartedCommand(
          name: 'a_sub_command',
          callback: (arguments, flags) {
            // With the console helper you could:
            // - Get an user input?
            ConsoleHelper.getUserInput(
                promptBuilder: (def, secToTimeout) => 'Give me your name!');
            // - Confirm an user's action?
            ConsoleHelper.confirm(
                prompt: 'Are you absolutely sure??',
                acceptedAffirmatives: ['Yea']);
            // - Execute a command?
            ConsoleHelper.executeCommand('flutter doctor -v');
            // - Load a task interactively?
            ConsoleHelper.loadWithTask(
                task: 'doing something...',
                process: () async =>
                    await Future.delayed(const Duration(seconds: 4)));
            // - **NEW in 0.1.11** Prompt the user to select an option interactively?
            List<int> theGottenChoices = ConsoleHelper.chooseOption(
              'Choose an option',
              ['Option 1', 'Option 2', 'Option 3'],
              isMultiSelect: true,
              unselectedIndicator: "[]",
              selectedIndicator: "[x]",
              selectionIndicator: "->",
            );
            ConsoleHelper.write('Got the choices: $theGottenChoices');
          },
          helperDescription: "A sub command for create.."),
    ],
  ),
  DartedCommand(
      name: 'another_command',
      callback: (arguments, flags) => PackageLogic.doSomething(),
      helperDescription: "Another top level command...")
];

void main(List<String> input) async => await dartedEntry(
      input: input,
      commandsTree: commandsTree,
      // The main entry command when someone types in [your_package]
      customEntryHelper: (tree) async {
        return await AsciiArtModule.textToAscii('DARTED',
            beforeEachLine: "|  ");
      },
      // Available commands, arguments, and flags to process.
      customVersionResponse: () => "when i get -v, here's a response!",
      // Oh yeah, the console helper has colors, background colors, and text modifiers!
      customHelpResponse: (command) =>
          'custom response for the -h flag?'.withColor(ConsoleColor.cyan),
    );
