import 'dart:async';
import 'dart:io';

/// Ask for user input asynchronously with support for timeout and default values.
///
/// Uses standard non-locking input reading to prevent stream conflicts with
/// synchronous interactive terminal tools.
Future<String> getUserInputImpl(
  String Function(String? defaultValue, int? secondsToTimeout) promptBuilder, {
  String? defaultValue,
  Duration? timeOut,
}) async {
  stdout.write(promptBuilder(defaultValue, timeOut?.inSeconds));

  if (timeOut == null) {
    try {
      final line = stdin.readLineSync();
      if (line == null || line.trim().isEmpty) {
        return defaultValue ?? '';
      }
      return line.trim();
    } catch (_) {
      return defaultValue ?? '';
    }
  }

  // Handle timeout safely without permanently locking stdin
  final inputCompleter = Completer<String>();
  Timer? timer;

  timer = Timer(timeOut, () {
    if (!inputCompleter.isCompleted) {
      inputCompleter.complete(defaultValue ?? '');
    }
  });

  Future(() {
    try {
      final line = stdin.readLineSync();
      if (!inputCompleter.isCompleted) {
        timer?.cancel();
        final result = (line == null || line.trim().isEmpty)
            ? (defaultValue ?? '')
            : line.trim();
        inputCompleter.complete(result);
      }
    } catch (e) {
      if (!inputCompleter.isCompleted) {
        timer?.cancel();
        inputCompleter.complete(defaultValue ?? '');
      }
    }
  });

  return await inputCompleter.future;
}
