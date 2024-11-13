import 'dart:async';
import 'dart:io';

abstract class BaseLoader {
  final Duration interval;
  final String? task;
  final List<String> animationFrames;
  final String completionSymbol;
  Timer? _timer;
  bool _isLoading = false;

  BaseLoader({
    this.interval = const Duration(milliseconds: 100),
    this.task,
    this.animationFrames = const ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'],
    this.completionSymbol = '\x1B[32m✓\x1B[0m', // Green check mark by default
  });

  void start() {
    int index = 0;
    _isLoading = true;
    _timer = Timer.periodic(interval, (timer) {
      if (_isLoading) {
        stdout.write('\r${animationFrames[index % animationFrames.length]} $task...');
        index++;
      } else {
        timer.cancel();
      }
    });
  }

  void stop() {
    _isLoading = false;
    stdout.write('\r$completionSymbol $task\n'); // Overwrite with the completion symbol
  }

  void animate(); // Abstract method for subclasses to define specific animations, if needed
}
