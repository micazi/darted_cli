import 'dart:async';
import 'dart:io';

// Extension to read asynchronously from stdin
extension StdinExtension on Stdin {
  Future<String?> readLineAsync() {
    return Future.sync(() => stdin.readLineSync());
  }
}

class ConsoleHelper {
  /* What i need in the console helper
  1- Input: Get user's input with a prompt, prompt styling, timout duration, clear prompt after getting, is optional. VARIATION: Ask confirmation.
  2- Output: Rewrite a line OR Write a new line. Colors, Alignment,Styling(Bold, underline, italic).
  3- Loading animations, Check marks, etc..  
  */

  void printToConsole(String text, {bool newLine = false, bool overwrite = false}) {
    if (newLine) {
      stdout.writeln(); // Print text followed by a newline
    }

    if (overwrite) {
      // Move the cursor to the beginning of the current line and overwrite it
      stdout.write('\x1B[2K'); // Clear current line
      stdout.write('\x1B[0G'); // Move cursor to the start of the line
    }

    stdout.write(text);
    // stdout.write('\x1B[${text.length}C');
  }

  void clearConsole() {
    stdout.write('\x1B[2J'); // Clear the screen
    stdout.write('\x1B[H'); // Move the cursor to the top-left corner
  }

  Future<String> askForInput(String Function(String? defaultValue, int? secondsToTimeout) promptBuilder, {String? defaultValue, Duration? timeOut}) async {
    // String? _userInput;
    // if (timeOut != null) {
    //   bool timedOut = false;
    //   // Start the timer.
    //   Timer _timer = Timer(timeOut, () {
    //     timedOut = true;
    //   });
    //   // Give the prompt..
    //   stdout.write(promptBuilder(defaultValue, _timer.tick));
    //   if (timedOut) {
    //     _timer.cancel();
    //     stdout.write('Time Out!');
    //   }
    //   // Wait for the user's input
    //   _userInput = stdin.readLineSync() ?? '';
    // } else {}
    // return _userInput ?? defaultValue ?? '';

    final inputCompleter = Completer<String>();
    final buffer = StringBuffer();
    stdout.write(promptBuilder(defaultValue, timeOut?.inSeconds));

    // Set up a timer if a timeout is specified
    Timer? timer;
    if (timeOut != null) {
      timer = Timer(timeOut, () {
        if (!inputCompleter.isCompleted) {
          inputCompleter.complete(defaultValue ?? '');
          stdout.writeln("\nTime's up!");
        }
      });
    }

    // Listen for user input asynchronously
    final subscription = stdin.listen((List<int> chars) {
      final String input = String.fromCharCodes(chars);
      if ((input.endsWith('\n')) || (input.endsWith('\r'))) {
        // Complete when Enter key is pressed
        if (!inputCompleter.isCompleted) {
          inputCompleter.complete(input.trim().isEmpty ? (defaultValue ?? '') : input);
        }
        timer?.cancel(); // Cancel the timer if input is received
      } else {
        buffer.write(input); // Append character to buffer
      }
    });

    // Complete the input completer when the future finishes
    inputCompleter.future.whenComplete(() {
      subscription.cancel();
    });

    return inputCompleter.future;
  }

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
  // String askForInput(String prompt) {
  //   stdout.write('$prompt: ');
  //   return stdin.readLineSync() ?? '';
  // }

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
  // String askWithTimeout(String prompt, Duration timeout, {String defaultValue = ''}) {
  //   stdout.write('$prompt (auto-selects "$defaultValue" in ${timeout.inSeconds} seconds): ');
  //   String? input;
  //   var timer = Timer(timeout, () => stdin(Stream<List<int>>.empty()));
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

  Future<void> logWithLoadingAnimation(String step) async {
    // Define colors and symbols for animation
    const loadingSymbols = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
    const checkMark = '\x1B[32m✓\x1B[0m'; // Green check mark
    const loadingTime = Duration(seconds: 4); // Simulated processing time

    int index = 0;
    bool animationComplete = false;

    // Start the animation with periodic updates
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (animationComplete) {
        // Stop the animation once completed
        timer.cancel();
      } else {
        // Display the loading animation
        stdout.write('\r${loadingSymbols[index % loadingSymbols.length]} $step...');
        index++;
      }
    });

    // Wait for the processing to complete (simulate loading time)
    await Future.delayed(loadingTime);

    // Mark the animation as complete after the loading time
    animationComplete = true;

    // Once the loading time is finished, explicitly print the check mark for the last step
    stdout.write('\r$checkMark $step\n');
  }
}
