// import 'dart:async';
// import 'dart:io';

// class ProgressBarLoader {
//   final int length;
//   final Duration interval;
//   late Timer _timer;
//   int _currentProgress = 0;

//   ProgressBarLoader({this.length = 20, this.interval = const Duration(milliseconds: 200)});

//   void start() {
//     stdout.write("[${' ' * length}]");
//     _timer = Timer.periodic(interval, (timer) {
//       if (_currentProgress < length) {
//         _currentProgress++;
//         stdout.write('\r[${'=' * _currentProgress}${' ' * (length - _currentProgress)}]');
//       } else {
//         stop();
//       }
//     });
//   }

//   void stop() {
//     _timer.cancel();
//     stdout.write('\r[${'=' * length}] Done!\n'); // Clear line after stopping
//   }
// }
