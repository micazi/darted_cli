import '../../../models/models.exports.dart';
import '../../../../helpers/helpers.exports.dart';
import '../print_constants.dart';

Future<void> callbackMapperImpl(
  List<DartedCommand> commandsTree,
  Map<String, (Map<String, dynamic> arguments, Map<String, bool> flags)>
      callStack, {
  String Function(DartedCommand command)? customHelpResponse,
  String Function()? customVersionResponse,
}) async {
  // Combine all commands & sub-commands.
  List<DartedCommand> allCommands = [];
  for (var c in commandsTree) {
    allCommands.add(c);
    allCommands.addAll(c.subCommands ?? []);
  }

  DartedCommand? lastCommand = callStack.isEmpty
      ? null
      : allCommands
          .where((comm) => comm.name == callStack.entries.last.key)
          .firstOrNull;

  // Filter arguments for duplications.
  Map<String, dynamic> filteredArguments = {};
  for (var arg in callStack.entries.last.value.$1.entries) {
    String? name = lastCommand?.arguments
        ?.where((aaa) => (aaa?.name == arg.key || aaa?.abbreviation == arg.key))
        .firstOrNull
        ?.name;
    String? abbr = lastCommand?.arguments
        ?.where((aaa) => (aaa?.name == arg.key || aaa?.abbreviation == arg.key))
        .firstOrNull
        ?.abbreviation;
    if (filteredArguments.containsKey(name) ||
        filteredArguments.containsKey(abbr)) {
      filteredArguments.removeWhere((a, v) => a == name || a == abbr);
      filteredArguments.addEntries([MapEntry(arg.key, arg.value)]);
    } else {
      filteredArguments.addEntries([MapEntry(arg.key, arg.value)]);
    }
  }

  // Filter flags for duplications.
  Map<String, bool> filteredFlags = {};
  for (var ff in callStack.entries.last.value.$2.entries) {
    String? name = lastCommand?.flags
        ?.where((aaa) => (aaa.name == ff.key || aaa.abbreviation == ff.key))
        .firstOrNull
        ?.name;
    String? abbr = lastCommand?.flags
        ?.where((aaa) => (aaa.name == ff.key || aaa.abbreviation == ff.key))
        .firstOrNull
        ?.abbreviation;
    if (filteredFlags.containsKey(name) || filteredFlags.containsKey(abbr)) {
      filteredFlags.removeWhere((a, v) => a == name || a == abbr);
      filteredFlags.addEntries([MapEntry(ff.key, ff.value)]);
    } else {
      filteredFlags.addEntries([MapEntry(ff.key, ff.value)]);
    }
  }

  // Supply default values for the non-supplied arguments.
  Map<String, dynamic> argumentsWithDefaultValue = Map.fromEntries(lastCommand
          ?.arguments
          ?.where((commArg) =>
              commArg?.defaultValue != null &&
              !filteredArguments.containsKey(commArg?.name) &&
              !filteredArguments.containsKey(commArg?.abbreviation))
          .toList()
          .map((a) => MapEntry(a?.name ?? '', a?.defaultValue)) ??
      {})
    ..removeWhere((k, v) => k.isEmpty);

  // Supply automatically applied flags that were not supplied.
  List<String> automaticallyAppliedFlags = lastCommand?.flags
          ?.where((f) =>
              f.appliedByDefault &&
              !filteredFlags.containsKey(f.name) &&
              !filteredFlags.containsKey(f.abbreviation))
          .toList()
          .map((ff) => ff.name)
          .toList() ??
      [];

  // Callback Handling
  if (lastCommand != null) {
    // Check for standard flags (Version / Help)
    if (filteredFlags.containsKey(DartedFlag.help.name) ||
        filteredFlags.containsKey(DartedFlag.help.abbreviation)) {
      ConsoleHelper.write(
        (customHelpResponse?.call(lastCommand) ??
            defaultHelperMessage(lastCommand)),
      );
      return;
    }

    if (filteredFlags.containsKey(DartedFlag.version.name) ||
        filteredFlags.containsKey(DartedFlag.version.abbreviation)) {
      ConsoleHelper.write(
        (customVersionResponse?.call() ?? await defaultVersionMessage()),
      );
      return;
    }

    // Call the command's supplied callback methods with the filtered data (The last command in the stack).
    lastCommand.callback({
      ...filteredArguments,
      ...argumentsWithDefaultValue
    }, {
      ...filteredFlags,
      ...Map.fromEntries(
          automaticallyAppliedFlags.map((f) => MapEntry(f, true)))
    });
  }
}
