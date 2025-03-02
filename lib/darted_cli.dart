import 'console_helper.dart';
import 'src/darted/models/darted_models.exports.dart';
import 'src/darted/helper/darted.helper.dart';
//
export 'src/darted/models/darted_models.exports.dart';
export 'src/darted/helper/darted.helper.dart';

Future<void> dartedEntry({
  required List<DartedCommand> commandsTree,
  required List<String> input,
  // Validation Customizations
  Future<String> Function(List<DartedCommand> commandsTree)? customEntryHelper,
  String Function(String, String?)? customCommandInvalidError,
  String Function(String, Map<String, dynamic>, String?)?
      customArgumentInvalidError,
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

  // Parse main argument if exists
  await DartedHelper.parseMainArg(commandsTree, callStack,
          customCommandInvalidError: customCommandInvalidError)
      .then((res) {
    if (res.$1 != null && res.$2 == null) {
      // No errors
      callStack = res.$1!;
    } else {
      // has error
      ConsoleHelper.write(res.$2!);
      ConsoleHelper.exit(1);
    }
  });

  // Validate against the call stack
  bool validated = true;
  await DartedHelper.validateCallStack(
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
  ).then((res) {
    if (!res.$1 && res.$2 != null) {
      validated = false;
      ConsoleHelper.write(res.$2!);
      ConsoleHelper.exit(1);
    }
  });

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
