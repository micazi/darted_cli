MapEntry<String, (Map<String, dynamic>, Map<String, bool>)>?
    parseCommandToCallStackImpl(
  String currentCommand,
  List<String> input,
  List<String> parsedCommands,
  Map<String, dynamic> parsedArguments,
  List<String> parsedFlags,
) {
  MapEntry<String, (Map<String, dynamic>, Map<String, bool>)>? ret;
  //
  int currentIndex = input.indexOf(currentCommand);
  String? next =
      parsedCommands.indexOf(currentCommand) + 1 >= parsedCommands.length
          ? null
          : parsedCommands[parsedCommands.indexOf(currentCommand) + 1];
  int? nextIndex = next == null ? null : input.indexOf(next);

  // Get unparsed data of the current command
  List<String> currentUnparsedData = input.sublist(currentIndex + 1, nextIndex);

  // Extract Arguments from the current unparsed data
  Map<String, dynamic> currentArguments = Map.fromEntries(parsedArguments
      .entries
      .where((s) => ((currentUnparsedData.contains("--${s.key}") &&
              currentUnparsedData[
                      currentUnparsedData.indexOf("--${s.key}") + 1] ==
                  s.value) ||
          (currentUnparsedData.contains("-${s.key}") &&
              currentUnparsedData[
                      currentUnparsedData.indexOf("-${s.key}") + 1] ==
                  s.value)))
      .toList());
  // Extract Arguments from the current unparsed data
  Map<String, bool> currentFlags = Map.fromEntries(parsedFlags.where((f) {
    return currentUnparsedData.contains("--$f") ||
        currentUnparsedData.contains("--no-$f") ||
        currentUnparsedData.contains("-$f");
  }).map((s) => MapEntry(s, !currentUnparsedData.contains("--no-$s"))));
  //
  ret = MapEntry(currentCommand, (currentArguments, currentFlags));
  return ret;
}
