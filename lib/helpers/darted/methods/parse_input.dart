parseInputImpl(List<String> input) {
  final commands = <String>[];
  final arguments = <String, String?>{};
  final flags = <String>[];

  // Loop through the input to sort for commands, arguments, and flags.
  for (var i = 0; i < input.length; i++) {
    final arg = input[i];

    // 1- has no '-'
    if (!arg.startsWith('-')) {
      if (i - 1 >= 0 && input[i - 1].startsWith('-')) {
        // Value for an argument
        // Skip.
      } else {
        // command
        commands.add(arg);
      }
    }
    // 2- has --s --some --no-some
    else if (arg.startsWith('--')) {
      if (arg.startsWith('--no-')) {
        // Negated Flag
        flags.add(arg.replaceAll('--no-', ''));
      } else if (i + 1 == input.length || input[i + 1].startsWith('-')) {
        // Flag
        flags.add(input[i].replaceAll('--', ''));
      } else {
        // Argument
        arguments.addEntries([MapEntry(input[i].replaceAll('-', ''), input[i + 1])]);
      }
    }
    // 3- has -s -some -no-some
    else if (arg.startsWith('-')) {
      if (arg.startsWith('-no-')) {
        // Negated Flag
        flags.add(arg.replaceAll('-no-', ''));
      } else if (i + 1 == input.length || input[i + 1].startsWith('-')) {
        // Flag
        flags.add(input[i].replaceAll('-', ''));
      } else {
        // Argument
        arguments.addEntries([MapEntry(input[i].replaceAll('-', ''), input[i + 1])]);
      }
    }
  }
  //
  return {'commands': commands, 'arguments': arguments, 'flags': flags};
}
