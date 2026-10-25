import '../models/loading/loader_base.dart';
//
import 'dart:async';
import 'dart:io';

class SpinnerLoader extends ConsoleLoaderBase {
  final List<String> spinnerSymbols = [
    '⠋',
    '⠙',
    '⠹',
    '⠸',
    '⠼',
    '⠴',
    '⠦',
    '⠧',
    '⠇',
    '⠏'
  ];
  int index = 0;

  SpinnerLoader({
    required super.task,
    super.speed,
    super.animationColor,
    super.animationPosition,
  });

  @override
  Future<void> start() async {
    isLoading = true;
    final interval = speed ?? const Duration(milliseconds: 100);
    Timer.periodic(interval, (timer) {
      if (!isLoading) {
        timer.cancel();
      } else {
        stdout.write(
            '\r${formatOutput(spinnerSymbols[index % spinnerSymbols.length])}');
        index++;
      }
    });
  }
}
