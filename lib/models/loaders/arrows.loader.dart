// import 'dart:io';

// import 'loader_base.dart';

// class ArrowsLoader extends BaseLoader {
//   int _currentIndex = 0;
//   final List<String> _arrowFrames = ['→', '⇒', '⇛', '⇶', '⇋'];

//   ArrowsLoader({super.interval = const Duration(milliseconds: 120)});

//   @override
//   void animate() {
//     stdout.write('\r${_arrowFrames[_currentIndex]} Loading   ');
//     _currentIndex = (_currentIndex + 1) % _arrowFrames.length;
//   }
// }
