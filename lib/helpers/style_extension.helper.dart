import 'dart:io';
import '../models/console/console_models.exports.dart';
//
export '../models/console/console_models.exports.dart';

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
    switch (alignment) {
      case ConsoleTextAlignment.left:
        return this;
      case ConsoleTextAlignment.center:
        return padLeft((stdout.terminalColumns + length) ~/ 2)
            .padRight(stdout.terminalColumns);
      case ConsoleTextAlignment.right:
        return padLeft(stdout.terminalColumns);
      default:
        return this;
    }
  }
}
