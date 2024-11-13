import 'dart:io';
import 'package:darted_cli/models/console/alignment.enum.dart';
import '../models/console/console_models.exports.dart';

extension DartedStyleExtension on String {
  String withColor(ConsoleColor color) => '${color.textCode}$this\x1B[0m';
  String withBackgroundColor(ConsoleColor color) => '${color.backgroundCode}$this\x1B[0m';
  String withTextStyle(ConsoleTextModifier modifier) => '${modifier.code}$this\x1B[0m';
  String withAlignment(ConsoleTextAlignment alignment) {
    switch (alignment) {
      case ConsoleTextAlignment.left:
        return this;
      case ConsoleTextAlignment.center:
        return padLeft((stdout.terminalColumns + length) ~/ 2).padRight(stdout.terminalColumns);
      case ConsoleTextAlignment.right:
        return padLeft(stdout.terminalColumns);
      default:
        return this;
    }
  }
}
