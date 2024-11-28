List<String> parseArguments(String commandWithArgs) {
  final args = <String>[];
  final parts = commandWithArgs.split(RegExp(r'\s+'));
  var i = 0;

  while (i < parts.length) {
    final part = parts[i];

    // Check if it's a flag, like `--platforms`
    if (part.startsWith('--')) {
      final flag = part;
      args.add(flag); // Add the flag to the list

      // Look ahead to see if there are values for this flag
      while (i + 1 < parts.length && !parts[i + 1].startsWith('--')) {
        args.add(parts[i + 1]); // Add flag value
        i++;
      }
    } else {
      // It's not a flag, so it's a command or regular argument
      args.add(part);
    }

    i++;
  }

  return args;
}
