enum ConsoleTextModifier {
  bold,
  italic,
  underline,
  //
  reverse,
  blink,
  reset,
}

extension TextModifiersExtension on ConsoleTextModifier {
  String get code {
    return switch (this) {
      ConsoleTextModifier.bold => '\x1B[1m',
      ConsoleTextModifier.italic => '\x1B[3m',
      ConsoleTextModifier.underline => '\x1B[4m',
      ConsoleTextModifier.reverse => '\x1B[7m',
      ConsoleTextModifier.blink => '\x1B[5m',
      ConsoleTextModifier.reset => '\x1B[0m',
    };
  }
}
