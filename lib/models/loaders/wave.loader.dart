// import 'dart:io';

// import 'loader_base.dart';

// class WaveLoader extends BaseLoader {
//   int _position = 0;
//   bool _goingRight = true;

//   WaveLoader({super.width, super.interval = const Duration(milliseconds: 80), super.task});

//   @override
//   void animate() {
//     String wave = '${'~' * _position}^${'~' * (width - _position)}';
//     stdout.write('\r$wave   ');
//     if (_goingRight) {
//       _position++;
//       if (_position >= width) _goingRight = false;
//     } else {
//       _position--;
//       if (_position <= 0) _goingRight = true;
//     }
//   }
// }
