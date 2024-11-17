import 'helpers/darted/darted.helper.dart';
import 'models/models.exports.dart';
//
export 'helpers/helpers.exports.dart';
export 'models/models.exports.dart';
export './loaders/loaders.exports.dart';
export './modules/modules.exports.dart';

Future<void> dartedEntry({
  required List<DartedCommand> commandsTree,
  required List<String> input,
  // Validation Customizations
  Future<String> Function(List<DartedCommand> commandsTree)? customEntryHelper,
  String Function(String)? customCommandInvalidError,
  String Function(String, Map<String, dynamic>)? customArgumentInvalidError,
  String Function(String, Map<String, dynamic>, List<String>)?
      customArgumentOptionsInvalidError,
  String Function(String, Map<String, bool>)? customFlagInvalidError,
  String Function(String, Map<String, bool>)? customFlagNegatedError,
  // Responses Customizations
  String Function(DartedCommand)? customHelpResponse,
  String Function()? customVersionResponse,
}) async {
  // Parse the input to Commands,Arguments, and Flags.
  Map<String, dynamic> parsedInputMap = DartedHelper.parseInput(input);
  List<String> parsedCommands = parsedInputMap['commands'];
  Map<String, dynamic> parsedArguments = parsedInputMap['arguments'];
  List<String> parsedFlags = parsedInputMap['flags'];

  // Identify the callstack with the hierarchial order.
  Map<String, (Map<String, dynamic> arguments, Map<String, bool> flags)>
      callStack = {};
  for (var currentParsedCommand in parsedCommands) {
    MapEntry<String, (Map<String, dynamic>, Map<String, bool>)>? entry =
        DartedHelper.parseCommandToCallStack(currentParsedCommand, input,
            parsedCommands, parsedArguments, parsedFlags);
    if (entry != null) {
      callStack.addEntries([entry]);
    }
  }

  String? customMainHelper = await customEntryHelper?.call(commandsTree);

  // Validate against the call stack
  bool validated = await DartedHelper.validateCallStack(
    commandsTree,
    callStack,
    //
    customEntryHelper: customMainHelper,
    customVersionResponse: customVersionResponse?.call(),
    customCommandInvalidError: customCommandInvalidError,
    customArgumentInvalidError: customArgumentInvalidError,
    customArgumentOptionsInvalidError: customArgumentOptionsInvalidError,
    customFlagInvalidError: customFlagInvalidError,
    customFlagNegatedError: customFlagNegatedError,
  );
  if (validated) {
    // return the callback
    await DartedHelper.callbackMapper(
      commandsTree,
      callStack,
      //
      customHelpResponse: customHelpResponse,
      customVersionResponse: customVersionResponse,
    );
  }
}
