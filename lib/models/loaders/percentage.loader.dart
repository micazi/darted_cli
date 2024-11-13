// import 'dart:io';

// import 'loader_base.dart';

// class PercentageLoader extends BaseLoader {
//   int _progress = 0;

//   PercentageLoader({super.width = 20, super.interval});

//   @override
//   void animate() {
//     _progress++;
//     double percentage = (_progress / width) * 100;
//     String bar = '[${'=' * _progress}${' ' * (width - _progress)}]';
//     stdout.write('\r$bar ${percentage.toStringAsFixed(0)}%   ');
//     if (_progress >= width) stop();
//   }
// }
