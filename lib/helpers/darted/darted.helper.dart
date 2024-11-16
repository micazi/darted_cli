import '../../models/models.exports.dart';
import 'methods/methods.exports.dart';

class DartedHelper {
  static Map<String, dynamic> parseInput(List<String> input) => parseInputImpl(input);

  //
  static MapEntry<String, (Map<String, dynamic>, Map<String, bool>)>? parseCommandToCallStack(
    String currentCommand,
    List<String> input,
    List<String> parsedCommands,
    Map<String, dynamic> parsedArguments,
    List<String> parsedFlags,
  ) =>
      parseCommandToCallStackImpl(currentCommand, input, parsedCommands, parsedArguments, parsedFlags);

  static Future<bool> validateCallStack(
    List<DartedCommand> commandsTree,
    Map<String, (Map<String, dynamic> arguments, Map<String, bool> flags)> callStack, {
    String? customEntryHelper,
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
        customEntryHelper: customEntryHelper,
        customCommandInvalidError: customCommandInvalidError,
        customArgumentInvalidError: customArgumentInvalidError,
        customArgumentOptionsInvalidError: customArgumentOptionsInvalidError,
        customFlagInvalidError: customFlagInvalidError,
        customFlagNegatedError: customFlagNegatedError,
      );

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
