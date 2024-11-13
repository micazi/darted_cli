// import 'dart:io';

// import 'loader_base.dart';

// class CircularDotsLoader extends BaseLoader {
//   int _currentIndex = 0;
//   final List<String> _circleFrames = ['◐', '◓', '◑', '◒'];

//   CircularDotsLoader({super.interval});

//   @override
//   void animate() {
//     stdout.write('\r${_circleFrames[_currentIndex]} Loading   ');
//     _currentIndex = (_currentIndex + 1) % _circleFrames.length;
//   }
// }
