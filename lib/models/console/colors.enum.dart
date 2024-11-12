enum ConsoleColor {
  black,
  grey,
  red,
  lightRed,
  green,
  lightGreen,
  yellow,
  lightYellow,
  blue,
  lightBlue,
  magenta,
  lightMagenta,
  cyan,
  lightCyan,
  white,
  lightWhite,
}

extension ConsoleColorExtension on ConsoleColor {
  String get textCode {
    return switch (this) {
      ConsoleColor.black => '\x1B[30m',
      ConsoleColor.grey => '\x1B[90m',
      ConsoleColor.red => '\x1B[31m',
      ConsoleColor.lightRed => '\x1B[91m',
      ConsoleColor.green => '\x1B[32m',
      ConsoleColor.lightGreen => '\x1B[92m',
      ConsoleColor.yellow => '\x1B[33m',
      ConsoleColor.lightYellow => '\x1B[93m',
      ConsoleColor.blue => '\x1B[34m',
      ConsoleColor.lightBlue => '\x1B[94m',
      ConsoleColor.magenta => '\x1B[35m',
      ConsoleColor.lightMagenta => '\x1B[95m',
      ConsoleColor.cyan => '\x1B[36m',
      ConsoleColor.lightCyan => '\x1B[96m',
      ConsoleColor.white => '\x1B[37m',
      ConsoleColor.lightWhite => '\x1B[97m',
    };
  }

  String get backgroundCode {
    return switch (this) {
      ConsoleColor.black => '\x1B[40m',
      ConsoleColor.grey => '\x1B[100m',
      ConsoleColor.red => '\x1B[41m',
      ConsoleColor.lightRed => '\x1B[101m',
      ConsoleColor.green => '\x1B[42m',
      ConsoleColor.lightGreen => '\x1B[102m',
      ConsoleColor.yellow => '\x1B[43m',
      ConsoleColor.lightYellow => '\x1B[103m',
      ConsoleColor.blue => '\x1B[44m',
      ConsoleColor.lightBlue => '\x1B[104m',
      ConsoleColor.magenta => '\x1B[45m',
      ConsoleColor.lightMagenta => '\x1B[105m',
      ConsoleColor.cyan => '\x1B[46m',
      ConsoleColor.lightCyan => '\x1B[106m',
      ConsoleColor.white => '\x1B[47m',
      ConsoleColor.lightWhite => '\x1B[107m',
    };
  }
}
