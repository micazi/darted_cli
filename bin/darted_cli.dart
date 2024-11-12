import 'package:darted_cli/darted_cli.dart';

void main(List<String> args) async => await dartedEntry(
      commandsTree: [
        DartedCommand(
          /// Needs to be the same as the package name.
          name: 'darted_cli',
          flags: [
            /// Easy helpers for standard flags.
            DartedFlag.version(),
            DartedFlag.help(),
          ],
          subCommands: [
            DartedCommand(
              name: 'create',
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
      //
      callbackMapper: (helper) async {
        // Customizing help and version responses
        helper.setHelpResponse("Custom help message for my CLI tool.");
        helper.setVersionResponse("darted_CLI custom version 2.0.1");
        // Customizing error responses
        // helper.setNoArgumentMatchError("Custom help message for my CLI tool.");

        // Define callbacks, using responses stored in CallbackHelper
        return {
          'help': () {
            helper.console.askForInput('get something: ');
          },
          'version': () => print(helper.versionResponse),
        };
      },
    );

/*
  What the user needs to configure:
  1- The commands tree
  2- For each command with the supplied arguments, Give in the callbacks. Supply a consoleHelper along with the callback.
  */

createFunction({required projectName}) async {
  await Future.delayed(const Duration(seconds: 2));
}
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