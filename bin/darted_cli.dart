import 'dart:io';

import 'package:darted_cli/darted_cli.dart';
import 'package:darted_cli/helpers/console.helper.dart';
import 'package:darted_cli/helpers/style_extension.helper.dart';
import 'package:darted_cli/models/console/alignment.enum.dart';
import 'package:darted_cli/models/console/colors.enum.dart';
import 'package:darted_cli/models/loaders/dots.loader.dart';
import 'package:darted_cli/models/loaders/progress_bar.loader.dart';
import 'package:darted_cli/models/loaders/spinner.loader.dart';
import 'package:darted_cli/models/loaders/wave.loader.dart';

void main(List<String> args) async {
  ConsoleHelper().printToConsole('Printing this at first'.withColor(ConsoleColor.green));
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
  await Future.delayed(Duration(seconds: 2));
  //
  // await ConsoleHelper().logWithLoadingAnimation('This is a step in here!');
  ConsoleHelper().printToConsole('', newLine: true);
  final loader = SpinnerLoader(interval: Duration(milliseconds: 200), task: 'Doing some here!');
  loader.start();
  await Future.delayed(Duration(seconds: 10));
  loader.stop();
  ConsoleHelper().printToConsole('', newLine: true);
  final loader2 = DotsLoader(interval: Duration(milliseconds: 200), task: 'Doing some other thing!');
  loader2.start();
  await Future.delayed(Duration(seconds: 10));
  loader2.stop();
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
  ConsoleHelper().printToConsole('');
  exit(0);
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