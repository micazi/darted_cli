# darted_cli

![Pub Version](https://img.shields.io/pub/v/darted_cli) ![Publisher](https://img.shields.io/pub/publisher/darted_cli) ![Pub Points](https://img.shields.io/pub/points/darted_cli) ![License](https://img.shields.io/github/license/micazi/darted_cli)

```bash
    ____             __           __    ________    ____
   / __ \____ ______/ /____  ____/ /   / ____/ /   /  _/
  / / / / __ `/ ___/ __/ _ \/ __  /   / /   / /    / /
 / /_/ / /_/ / /  / /_/  __/ /_/ /   / /___/ /____/ /
/_____/\__,_/_/   \__/\___/\__,_/____\____/_____/___/
                               /_____/
```

**`darted_cli`** is a powerful and developer-friendly Dart package for building feature-rich, structured command-line interfaces (CLI). It simplifies the process of creating command trees, parsing arguments and flags, and handling input validation with a focus on developer experience and ease of use.

You can see how to implement your next big idea using _darted_cli_ through [This Blog Post](https://medium.com/towardsdev/heres-what-i-built-with-darted-cli-meet-flutter-loc-0cbb33c1138d).

---

## Table of Contents

1. [Features](#features)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Developer Experience](#developer-experience)
5. [Featurs / Requests](#featurs-and-requests)
6. [License](#license)

---

## Features

- **Command Tree Validation**: Ensures commands follow the hierarchy and validates parent-child relationships.
- **Argument Parsing**: Supports named and multi-option arguments with default values.
- **Flag Parsing**: Handles boolean flags and their negations (e.g., `--no-flag`).
- **Call Stack Management**: Tracks commands, arguments, and flags in execution order.
- **Error Handling**: Provides descriptive errors for invalid commands, arguments, or flags.
- **Help and Version Flags**: Built-in support for `--help` and `--version` flags.
- **Console Management**: Display formatted output with colors and styles.
- **Extensibility**: Easily add custom commands, arguments, and flags.
- **Customizable Responses**: Define custom error messages for invalid inputs.
- **Interactive CLI**: Generate dynamic help text for commands.
- **Developer-Friendly**: Focused on ease of use with minimal boilerplate.

---

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  darted_cli: [latest_version]
```

Then, run:

```bash
dart pub get
```

## Usage

#### 1. Define your Commands

Define your CLI commands using a tree structure:

```dart
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
          DartedArgument(name: 'name', abbreviation: 'n', defaultValue: 'new_flutter_project', isMultiOption: false),
          // You also have the option to allow an argument to have multible options, with input validation based on the accepted options YOU enter!
          DartedArgument(name: 'platforms', abbreviation: 'p', acceptedMultiOptionValues: 'android,ios,web', isMultiOption: true, optionsSeparator: ','),
          // - **NEW in 0.1.5** Set an argument as 'Main', This will make it required and positional. 
          // e.g `your_package create the/path/required`
          DartedArgument(name: 'path', abbreviation: 'p', isMainReq: true),
        ],
        // Now, give it the flags allowed for this specific command, You can allow it to be negated too! (--no-flag)
        flags: [
          // Provided flag template for the --help/-h flag, it's automatically captured and you can customize it's output!
          DartedFlag.help,
          // Oh, and you can also allow flags to be applied by default even if they are not passed in..
          DartedFlag(name: 'package', abbreviation: 'pa', canBeNegated: false, appliedByDefault: true),
          DartedFlag(name: 'solo', abbreviation: 's', canBeNegated: true, appliedByDefault: false),
        ],
        // And finally, give your command a callback based on the arguments and flags you get. It can't get any easier!
        callback: (arguments, flags) => ConsoleHelper.write(
          '${'This command is ' 'create'.withColor(ConsoleColor.green)} I have the arguments: $arguments, and the flags: $flags',
        ),
        subCommands: [
          DartedCommand(name: 'a_sub_command',
          helperDescription: "A sub command for create..",
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
          ),
        ],
      ),
      DartedCommand(name: 'another_command', callback: (arguments, flags) {}, helperDescription: "Another top level command...")
    ];
```

#### 2. Extend your callback powers with our helpers!

##### Console Helper

```dart
// Get the user's input (with default value and time-out support!)
ConsoleHelper.getUserInput(promptBuilder: (defValue, timeout) => 'enter something...');

// Write out to the console
ConsoleHelper.write("Here's an output!...");

// That's just the easy stuff!

```

##### I/O Helper

```dart
// All the basic stuff! Creating, deleting, reading, and writing to files and directories.
// Some more exciting things? Here you go..

// List all files in here?
IOHelper.list('lib');

// Find all the files with a custom RegExp pattern and get all their pathes?
IOHelper.files.findAdvanced('lib',RegExp(r'*.yaml'));

// Search all the files in a directory for a specific keyword? Ignore hidded files? exclude some files? All There!
IOHelper.files.search('lib',RegExp(r'someWord'), exclude: [main.dart], ignoreHidden: true);

// Replacing the keyword, renaming, moving, and more, Just check the docs!

```

##### Some more stuff we're too modest to mention?

- Loading YAML files and quick parsing?
- ASCII artwork support to get those pretty prints?
- In-console loading animations for those step-by-step tasks?
- ? ( Leave feature request or contribute!)

#### 3. Execute it

Create a main entry point:

```dart
import 'package:darted_cli/darted_cli.dart';

void main(List<String> input) async => await dartedEntry(
      input: input,
      commandsTree: commandsTree,
      // The main entry command when someone types in [your_package]
      customEntryHelper: (tree) async {
       return await AsciiArtModule.textToAscii('DARTED', beforeEachLine: "|  ");
      },
      // Available commands, arguments, and flags to process.
      customVersionResponse: () => "when i get -v, here's a response!",
      // Oh yeah, the console helper has colors, background colors, and text modifiers!
      customHelpResponse: () => 'custom response for the -h flag?'
      .withColor(ConsoleColor.cyan),
    );

```

So when the user enters

```bash
dart run my_package create --name project_name -p android,ios
```

You get:

```yaml
Command: create
Arguments: { name: project_name, platforms: [android, ios] }
Flags: { package: true, solo: false }
```

Now,
Done building your **1-billion dollar** CLI Tool?

Run the script in your terminal

```bash
dart run [your_package] create --name my_project -flag --no-flag
```

Or upload it so we all get to take a look!

## Developer Experience

darted_cli is designed with developers in mind, offering:

- **Ease of Use**: Focus on defining your command logic instead of boilerplate code.
- **Minimal Setup**: Get started quickly with built-in argument and flag parsing.
- **Customizability**: Tailor commands, error messages, and output to suit your needs.
- **Interactive Debugging**: Test your command hierarchy with detailed validation output.
- **Scalable Design**: Add commands, subcommands, and features without breaking existing functionality.

#### Why Choose darted_cli?

- **Save Time**: No need to reimplement parsing logic or validation checks.
- **Focus on Logic**: Concentrate on the functionality of your CLI application.
- **Reliable Framework**: Built to handle both simple and complex CLI needs.

## Featurs and Requests

- [x] Adding custom Ascii art fonts.
- [x] Adding Command Execution functionality.
- [x] Adding Prompt to choose an option.
- [ ] Adding option to compile.
- [ ] Adding more animated loaders.
- [ ] You tell me!

## License

Licensed under the MIT License. You are free to use, modify, and distribute this package.
