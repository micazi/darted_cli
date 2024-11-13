// import 'dart:io';

// import 'loader_base.dart';

// class PulseLoader extends BaseLoader {
//   int _size = 1;
//   bool _growing = true;

//   PulseLoader({super.interval = const Duration(milliseconds: 300)});

//   @override
//   void animate() {
//     stdout.write('\r${'.' * _size}   '); // Clear previous dots with spaces
//     _growing ? _size++ : _size--;
//     if (_size == 5) _growing = false;
//     if (_size == 1) _growing = true;
//   }
// }
