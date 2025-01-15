import 'dart:async';
import 'dart:io';

// Global broadcast stream for stdin
final stdinBroadcast = stdin.asBroadcastStream();

/// Ask for user input asynchronously with support for timeout and default values
Future<String> getUserInputImpl(
  String Function(String? defaultValue, int? secondsToTimeout) promptBuilder, {
  String? defaultValue,
  Duration? timeOut,
}) async {
  stdout.write(promptBuilder(defaultValue, timeOut?.inSeconds));

  final inputCompleter = Completer<String>();
  final buffer = StringBuffer();

  // Set up timeout if specified
  Timer? timer;
  if (timeOut != null) {
    timer = Timer(timeOut, () {
      if (!inputCompleter.isCompleted) {
        inputCompleter.complete(defaultValue ?? '');
      }
    });
  }

  // Create a subscription to the shared broadcast stream
  final subscription = stdinBroadcast.listen(
    (List<int> data) {
      final input = String.fromCharCodes(data);
      if (input.endsWith('\n') || input.endsWith('\r')) {
        final completeInput = (buffer.toString() + input).trim();
        if (!inputCompleter.isCompleted) {
          final result =
              completeInput.isEmpty ? (defaultValue ?? '') : completeInput;
          inputCompleter.complete(result);
        }
        timer?.cancel();
      } else {
        buffer.write(input);
      }
    },
    onError: (error) {
      if (!inputCompleter.isCompleted) {
        inputCompleter.completeError(error);
      }
    },
  );

  try {
    final result = await inputCompleter.future;
    return result;
  } finally {
    await subscription.cancel();
  }
}
