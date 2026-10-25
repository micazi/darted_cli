import 'colors.enum.dart';
import 'text_modifiers.enum.dart';
import 'alignment.enum.dart';
import 'dart:io';

extension DartedStyleExtension on String {
  /// Color this string with provided color codes, just use [ConsoleColor]
  String withColor(ConsoleColor color) => '${color.textCode}$this\x1B[0m';

  /// Color the background of this string with provided color codes, just use [ConsoleColor]
  String withBackgroundColor(ConsoleColor color) =>
      '${color.backgroundCode}$this\x1B[0m';

  /// Change the style of this string with provided text modifiers, just use [ConsoleTextModifier]
  String withTextStyle(ConsoleTextModifier modifier) =>
      '${modifier.code}$this\x1B[0m';

  /// Change the alignment style of this string with provided alignment modifiers, just use [ConsoleTextAlignment]
  String withAlignment(ConsoleTextAlignment alignment) {
    final terminalWidth = _getSafeTerminalColumns();
    final visibleLen = _getVisibleLength(this);

    switch (alignment) {
      case ConsoleTextAlignment.left:
        return this;
      case ConsoleTextAlignment.center:
        final padCount =
            ((terminalWidth - visibleLen) ~/ 2).clamp(0, terminalWidth);
        return (' ' * padCount) + this;
      case ConsoleTextAlignment.right:
        final padCount = (terminalWidth - visibleLen).clamp(0, terminalWidth);
        return (' ' * padCount) + this;
    }
  }

  static int _getSafeTerminalColumns() {
    try {
      if (stdout.hasTerminal) {
        return stdout.terminalColumns;
      }
    } catch (_) {
      // Ignored: fallback to standard default width
    }
    return 80;
  }

  static int _getVisibleLength(String str) {
    return str.replaceAll(RegExp(r'\x1B\[[0-9;]*[a-zA-Z]'), '').length;
  }
}
