enum TextModifiers {
  bold,
  italic,
  underline,
  //
  reverse,
  blink,
  reset,
}

extension TextModifiersExtension on TextModifiers {
  String get code {
    return switch (this) {
      TextModifiers.bold => '\x1B[1m',
      TextModifiers.italic => '\x1B[3m',
      TextModifiers.underline => '\x1B[4m',
      TextModifiers.reverse => '\x1B[7m',
      TextModifiers.blink => '\x1B[5m',
      TextModifiers.reset => '\x1B[0m',
    };
  }
}
