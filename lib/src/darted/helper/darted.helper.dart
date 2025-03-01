import '../models/darted_models.exports.dart';
import 'methods/main_arg_parser.dart';
import 'methods/methods.exports.dart';

class DartedHelper {
  /// Map & Parse the input arguments.
  static Map<String, dynamic> parseInput(List<String> input) => parseInputImpl(input);

  /// Parse the commands, arguments, and flags into a CallStack.
  static MapEntry<String, (Map<String, dynamic>, Map<String, bool>)>? parseCommandToCallStack(
    String currentCommand,
    List<String> input,
    List<String> parsedCommands,
    Map<String, dynamic> parsedArguments,
    List<String> parsedFlags,
  ) =>
      parseCommandToCallStackImpl(currentCommand, input, parsedCommands, parsedArguments, parsedFlags);

  /// Parse main argument if exists.
  static parseMainArg(List<DartedCommand> commandsTree, Map<String, (Map<String, dynamic> arguments, Map<String, bool> flags)> callStack, {  String Function(String command)? customCommandInvalidError}) async =>
      parseMainArgImpl(commandsTree: commandsTree, callStack: callStack,customCommandInvalidError:customCommandInvalidError);

  /// Validate the callStack against the provided commandsTree.
  static Future<bool> validateCallStack(
    List<DartedCommand> commandsTree,
    Map<String, (Map<String, dynamic> arguments, Map<String, bool> flags)> callStack, {
    String? customEntryHelper,
    String? customVersionResponse,
    String Function(String command)? customCommandInvalidError,
    String Function(String command, Map<String, dynamic> argument)? customArgumentInvalidError,
    String Function(String command, Map<String, dynamic> argument, List<String> acceptedOptions)? customArgumentOptionsInvalidError,
    String Function(String command, Map<String, bool> flag)? customFlagInvalidError,
    String Function(String command, Map<String, bool> flag)? customFlagNegatedError,
  }) async =>
      await validateCallStackImpl(
        commandsTree,
        callStack,
        //
        customVersionResponse: customVersionResponse,
        customEntryHelper: customEntryHelper,
        customCommandInvalidError: customCommandInvalidError,
        customArgumentInvalidError: customArgumentInvalidError,
        customArgumentOptionsInvalidError: customArgumentOptionsInvalidError,
        customFlagInvalidError: customFlagInvalidError,
        customFlagNegatedError: customFlagNegatedError,
      );

  /// Map the commands to their callbacks.
  static Future<void> callbackMapper(
    List<DartedCommand> commandsTree,
    Map<String, (Map<String, dynamic> arguments, Map<String, bool> flags)> callStack, {
    String Function(DartedCommand command)? customHelpResponse,
    String Function()? customVersionResponse,
  }) async =>
      await callbackMapperImpl(
        commandsTree,
        callStack,
        customHelpResponse: customHelpResponse,
        customVersionResponse: customVersionResponse,
      );
}
