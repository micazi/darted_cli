import 'dart:async';
import 'dart:io';

/// Ask for user input asynchronously, You can add a timeout period and a default value (When the timeout runs or when he enters an empty value).
Future<String> getUserInputImpl(
  String Function(String? defaultValue, int? secondsToTimeout) promptBuilder, {
  String? defaultValue,
  Duration? timeOut,
}) async {
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
  final subscription = stdin.asBroadcastStream().listen((List<int> chars) {
    final String input = String.fromCharCodes(chars);
    if ((input.endsWith('\n')) || (input.endsWith('\r'))) {
      // Complete when Enter key is pressed
      if (!inputCompleter.isCompleted) {
        inputCompleter
            .complete(input.trim().isEmpty ? (defaultValue ?? '') : input);
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
