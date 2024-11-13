import 'dart:async';
import 'dart:io';
import '../models/console/loading/loader_position.enum.dart';
import '../models/console/loading/loader_base.dart';

class SpinnerLoader extends ConsoleLoaderBase {
  final List<String> spinnerSymbols = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
  int index = 0;

  SpinnerLoader({
    required super.task,
    super.speed,
    super.animationColor,
    super.animationPosition = LoaderPosition.after,
  });

  @override
  Future<void> start() async {
    isLoading = true;
    Timer.periodic(speed, (timer) {
      if (!isLoading) {
        timer.cancel();
      } else {
        stdout.write('\r${formatOutput(spinnerSymbols[index % spinnerSymbols.length])}');
        index++;
      }
    });
  }
}
