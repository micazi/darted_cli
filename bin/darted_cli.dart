/* 
  1- Console
    A- Read input
    B- Write lines
    B- Confirm
    B- Loading step
  2- Io
    A- CRUD Directories
    B- CRUD Files
    C - Search
  3- Modules
    A- YAML
    B- EXCEL 
  */
import 'dart:io';

import 'package:darted_cli/helpers/console/console.helper.dart';
import 'package:darted_cli/helpers/style_extension.helper.dart';
import 'package:darted_cli/models/console/console_models.exports.dart';

void main(List<String> args) async {
  //S1 -- Console Methods
  //S2 -- Write to the console
  ConsoleHelper.write('Hello and welcome to the DARTDED CLI'.withColor(ConsoleColor.green));
  ConsoleHelper.writeSpace();
  await Future.delayed(Duration(seconds: 2));
  //S2 -- Read User input
  // await ConsoleHelper.getUserInput((defValue, timeut) => 'can i get something from you?').then((v) {
  //   ConsoleHelper.write('I have got a value!: '.withColor(ConsoleColor.green) + v.withTextStyle(ConsoleTextModifier.bold));
  // });
  //S2 -- Confirm
  // await ConsoleHelper.confirm(prompt: 'Are you absolutely sure about this??').then((v) {
  //   ConsoleHelper.write('Seems like he is '.withColor(ConsoleColor.blue) +
  //       (v ? 'sure'.withTextStyle(ConsoleTextModifier.bold).withColor(ConsoleColor.green) : 'hesitent'.withTextStyle(ConsoleTextModifier.bold).withColor(ConsoleColor.red)));
  // });
  // ConsoleHelper.writeSpace();
  //S2 -- Loading Steps
  await ConsoleHelper.loadWithTask(
    task: 'This is a 4s delay!'.withTextStyle(ConsoleTextModifier.bold).withTextStyle(ConsoleTextModifier.italic).withTextStyle(ConsoleTextModifier.underline),
    process: () async {
      await Future.delayed(const Duration(seconds: 4));
    },
    loader: ConsoleLoader.progressBar,
    loaderColor: ConsoleColor.lightMagenta,
    loaderSpeed: Duration(milliseconds: 200),
    loaderPosition: LoaderPosition.before,
    //
    loaderSuccessReplacement: '✓'.withColor(ConsoleColor.blue).withTextStyle(ConsoleTextModifier.bold),
    //
  );
  // ConsoleHelper.writeSpace();
  //S1 --
  //
  // // Create a directory
  // await DirectoryUtils.createDirectory('testDir');

  // // Write to a file
  // await FileUtils.writeFile(
  //   'testDir/test.txt',
  //   'Hello, Dart! This is the content of a file i have!',
  // );

  // // Read from a file
  // String content = await FileUtils.readFile('testDir/test.txt');
  // ConsoleHelper().printToConsole(content.withColor(ConsoleColor.blue), newLine: true);

  // // Print directory tree
  // await DirectoryTreeUtils.printDirectoryTree('testDir');
  // final loader = SpinnerLoader(speed: Duration(milliseconds: 200), task: 'Deleting the folder!', animationPosition: AnimationPosition.after);
  // loader.start();
  // await DirectoryUtils.deleteDirectory('testDir');
  // await Future.delayed(Duration(seconds: 2));
  // loader.stop();

  // // Check if a file exists
  // bool fileExists = await FileExistenceUtils.fileExists('testDir/test.txt');
  // print(fileExists); // Output: true

  // // Rename a file
  // await DirectoryUtils.renameFile('testDir/test.txt', 'testDir/renamed.txt');

  // // Delete the file and directory
  // await FileUtils.deleteFile('testDir/renamed.txt');
  // ConsoleHelper().printToConsole('This is with new Line'.withColor(ConsoleColor.blue), newLine: true);
  // // await Future.delayed(Duration(seconds: 3));
  // ConsoleHelper().printToConsole('This is  with another new line'.withColor(ConsoleColor.red), newLine: true);
  // // await Future.delayed(Duration(seconds: 3));
  // ConsoleHelper().printToConsole('This is replacing before last line'.withColor(ConsoleColor.red), overwrite: true);
  // // await Future.delayed(Duration(seconds: 2));
  // ConsoleHelper().printToConsole('This is with new Line'.withColor(ConsoleColor.blue), newLine: true);
  // // await Future.delayed(Duration(seconds: 2));
  // ConsoleHelper().printToConsole('This is replacing last line'.withColor(ConsoleColor.blue), overwrite: true);
  // await Future.delayed(Duration(seconds: 2));
  // // await ConsoleHelper().progressBar('This is a message!', 150);
  // await Future.delayed(Duration(seconds: 2));
  // ConsoleHelper().printToConsole('This is left...'.withAlignment(ConsoleTextAlignment.left), newLine: true);
  // ConsoleHelper().printToConsole('This is center...'.withAlignment(ConsoleTextAlignment.center), newLine: true);
  // ConsoleHelper().printToConsole('This is right...'.withAlignment(ConsoleTextAlignment.right), newLine: true);
  // await Future.delayed(Duration(seconds: 2));
  //
  // await ConsoleHelper().logWithLoadingAnimation('This is a step in here!');
  // ConsoleHelper().printToConsole('', newLine: true);
  // final loader = SpinnerLoader(speed: Duration(milliseconds: 200), task: 'Doing some here!', animationPosition: AnimationPosition.after);
  // loader.start();
  // await Future.delayed(Duration(seconds: 4));
  // loader.stop();
  // ConsoleHelper().printToConsole('', newLine: true);
  // final loader2 = DotsLoader(interval: Duration(milliseconds: 200), task: 'Doing some other thing!');
  // loader2.start();
  // await Future.delayed(Duration(seconds: 4));
  // loader2.stop();
  // final loader3 = ProgressBarLoader(barWidth: 20, speed: Duration(milliseconds: 200), task: 'Doing some other thing!', animationPosition: AnimationPosition.before);
  // loader3.start();
  // await Future.delayed(Duration(seconds: 4));
  // loader3.stop();
  // await Future.delayed(Duration(seconds: 2));
  // final loader2 = DotsLoader();
  // loader2.start();
  // await Future.delayed(Duration(seconds: 3));
  // loader2.stop();
  // await Future.delayed(Duration(seconds: 2));
  // final loader3 = ProgressBarLoader();
  // loader3.start();
  // await Future.delayed(Duration(seconds: 3));
  // loader3.stop();
  // await Future.delayed(Duration(seconds: 2));
  // ConsoleHelper().printToConsole('');
  await Future.delayed(const Duration(seconds: 3));
  ConsoleHelper.exit(0, withClearing: false, withNewLine: true);
  // String d = await ConsoleHelper().askForInput(
  //   (defValue, timeToTimeout) =>
  //       'Give me something.'.withColor(ConsoleColor.blue) + '(def is $defValue, timeout in $timeToTimeout)'.withColor(ConsoleColor.magenta).withBackgroundColor(ConsoleColor.black),
  //   defaultValue: 'The default',
  //   timeOut: Duration(seconds: 10),
  // );
  // print('i got $d');
}

// void main(List<String> args) async => await dartedEntry(
//       commandsTree: [
//         DartedCommand(
//           /// Needs to be the same as the package name.
//           name: 'darted_cli',
//           flags: [
//             /// Easy helpers for standard flags.
//             DartedFlag.version(),
//             DartedFlag.help(),
//           ],
//           subCommands: [
//             DartedCommand(
//               name: 'create',
//               arguments: [
//                 DartedArgument(name: 'name', abbreviation: 'n', defaultValue: 'new_flutter_project', isMultiOption: false),
//                 DartedArgument(name: 'platforms', abbreviation: 'p', acceptedMultiOptionValues: 'android/ios/web', isMultiOption: true, optionsSeparator: '/'),
//               ],
//               flags: [
//                 DartedFlag.help(),
//               ],
//             ),
//           ],
//         ),
//       ],
//       //
//       callbackMapper: (helper) async {
//         // Customizing help and version responses
//         helper.setHelpResponse("Custom help message for my CLI tool.");
//         helper.setVersionResponse("darted_CLI custom version 2.0.1");
//         // Customizing error responses
//         // helper.setNoArgumentMatchError("Custom help message for my CLI tool.");

//         // Define callbacks, using responses stored in CallbackHelper
//         return {
//           'help': () {
//             helper.console.askForInput('get something: ');
//           },
//           'version': () => print(helper.versionResponse),
//         };
//       },
//     );

/*
  What the user needs to configure:
  1- The commands tree
  2- For each command with the supplied arguments, Give in the callbacks. Supply a consoleHelper along with the callback.
  */

// createFunction({required projectName}) async {
//   await Future.delayed(const Duration(seconds: 2));
// }
 // Helper has the current command stack
      //   helper.commandStack
      //   // Helper has the arguments
      //   helper.arguments
      //   // Helper has the flags
      //   helper.flags
      //   // Helper has Error response when no command found, no argument found, or no flag found
      //   helper.setNoCommandResponse
      //   helper.setNoArgumentResponse
      //   helper.setNoFlagResponse
      //   // Helper has readymade version and help responses
      //   helper.setHelpResponse
      //   helper.helpResponse
      //   helper.setVersionResponse
      //   helper.versionResponse
      //   // Helper has Text Input, Ask for response, and confirming 
      //   helper.ask()
      //   helper.confirm()
      //   helper.write()withColor, withBackgroundColor, withAllignment 
      //   // Helper has ui modifiers (Colors, Background colors, allignment, and loading)
      //   helper.startLoading()
      //   helper.replaceLoading()
      //   helper.resetLoading()
      //   // Helper has matching to a query string and reply based on it.
      //   helper.match(someQueryString)
      // return {
      //   'darted_cli -> create [projectName] (someFlag,!someFlag2)': createFunction(projectName: helper.arguments['projectName']),
      // };