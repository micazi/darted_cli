import 'helpers/darted/darted.helper.dart';
import 'models/models.exports.dart';
//
export 'helpers/helpers.exports.dart';
export 'models/models.exports.dart';

Future<void> dartedEntry({
  required List<DartedCommand> commandsTree,
  required List<String> input,
}) async {
  // Parse the input to Commands,Arguments, and Flags.
  Map<String, dynamic> parsedInputMap = DartedHelper.parseInput(input);
  List<String> parsedCommands = parsedInputMap['commands'];
  Map<String, dynamic> parsedArguments = parsedInputMap['arguments'];
  List<String> parsedFlags = parsedInputMap['flags'];

  // Identify the callstack with the hierarchial order.
  Map<String, (Map<String, dynamic> arguments, Map<String, bool> flags)> callStack = {};
  for (var currentParsedCommand in parsedCommands) {
    MapEntry<String, (Map<String, dynamic>, Map<String, bool>)>? entry = DartedHelper.parseCommandToCallStack(currentParsedCommand, input, parsedCommands, parsedArguments, parsedFlags);
    if (entry != null) {
      callStack.addEntries([entry]);
    }
  }

  // Validate against the call stack
  bool validated = DartedHelper.validateCallStack(commandsTree, callStack);

  if (validated) {
    // return the callback
    DartedHelper.callbackMapper(commandsTree, callStack);
  }
}
