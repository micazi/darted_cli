import 'dart:async';
import 'dart:io';

class ConsoleHelper {
  /* What i need in the console helper
  1- Input: Get user's input with a prompt, prompt styling, timout duration, clear prompt after getting, is optional. VARIATION: Ask confirmation.
  2- Output: Rewrite a line OR Write a new line. Colors, Alignment,Styling(Bold, underline, italic).
  3- Loading animations, Check marks, etc..  
  */

  // Inline output to update the same console line
  void inlineOutput(String message) {
    stdout.write('\r$message');
  }

  void clearLine() {
    stdout.write('\r${' ' * stdout.terminalColumns}\r');
  }

  // Print styled message
  void printStyled(String message, {String color = _reset, bool bold = false, bool underline = false, bool italic = false}) {
    final boldCode = bold ? _bold : '';
    final underlineCode = underline ? _underline : '';
    final italicCode = italic ? _italic : '';
    print('$boldCode$underlineCode$italicCode$color$message$_reset');
  }

  // Colors and styles
  static const String _reset = '\x1B[0m';
  static const String _bold = '\x1B[1m';
  static const String _underline = '\x1B[4m';
  static const String _italic = '\x1B[3m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String blue = '\x1B[34m';
  static const String yellow = '\x1B[33m';

  // Ask user for input
  String askForInput(String prompt) {
    stdout.write('$prompt: ');
    return stdin.readLineSync() ?? '';
  }

  // Confirm action with yes/no
  bool confirm(String message, {String affirmative = 'y', String negative = 'n'}) {
    stdout.write('$message ($affirmative/$negative): ');
    final response = stdin.readLineSync()?.toLowerCase();
    return response == affirmative;
  }

  // Loading spinner animation
  Future<void> loadingSpinner(String message, Duration duration) async {
    const spinnerIcons = ['|', '/', '-', '\\'];
    final end = DateTime.now().add(duration);
    int index = 0;
    while (DateTime.now().isBefore(end)) {
      inlineOutput('$message ${spinnerIcons[index]}');
      index = (index + 1) % spinnerIcons.length;
      await Future.delayed(Duration(milliseconds: 100));
    }
    clearLine();
  }

  // Progress bar
  Future<void> progressBar(String message, int steps) async {
    for (int i = 0; i <= steps; i++) {
      final percent = (i / steps * 100).toInt();
      final bar = ('#' * i).padRight(steps, '-');
      inlineOutput('$message [$bar] $percent%');
      await Future.delayed(Duration(milliseconds: 100));
    }
    clearLine();
    print('$message [${'#' * steps}] 100% Complete!');
  }

  // Timeout for user input with default response
  //  String askWithTimeout(String prompt, Duration timeout, {String defaultValue = ''}) {
  //   stdout.write('$prompt (auto-selects "$defaultValue" in ${timeout.inSeconds} seconds): ');
  //   String? input;
  //   var timer = Timer(timeout, () => stdin (Stream<List<int>>.empty()));
  //   input = stdin.readLineSync();
  //   timer.cancel();
  //   return input ?? defaultValue;
  // }

  // Selection menu for multiple choice
  String selectionMenu(String prompt, List<String> options) {
    print('$prompt:');
    for (int i = 0; i < options.length; i++) {
      print('  ${i + 1}. ${options[i]}');
    }
    stdout.write('Choose an option (1-${options.length}): ');
    int? choice = int.tryParse(stdin.readLineSync() ?? '');
    while (choice == null || choice < 1 || choice > options.length) {
      stdout.write('Invalid choice, please select again: ');
      choice = int.tryParse(stdin.readLineSync() ?? '');
    }
    return options[choice - 1];
  }

  // Align text
  String alignText(String text, {String alignment = 'left', int width = 80}) {
    switch (alignment) {
      case 'center':
        int leftPadding = (width - text.length) ~/ 2;
        return ' ' * leftPadding + text;
      case 'right':
        int leftPadding = width - text.length;
        return ' ' * leftPadding + text;
      default: // 'left'
        return text.padRight(width);
    }
  }

  // Helper to display themed output
  void printSuccess(String message) => printStyled(message, color: green, bold: true);
  void printError(String message) => printStyled(message, color: red, bold: true);
  void printWarning(String message) => printStyled(message, color: yellow, bold: true);
  void printInfo(String message) => printStyled(message, color: blue, italic: true);
}
