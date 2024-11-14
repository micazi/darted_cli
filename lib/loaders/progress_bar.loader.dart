import 'dart:async';
import 'dart:io';

import '../models/console/loading/loader_base.dart';

class ProgressBarLoader extends ConsoleLoaderBase {
  final int barWidth;

  ProgressBarLoader({
    super.task,
    this.barWidth = 10,
    super.speed,
    super.animationColor,
    super.animationPosition,
  });

  @override
  Future<void> start() async {
    isLoading = true;
    int progress = 0;

    Timer.periodic(speed!, (timer) {
      if (!isLoading) {
        timer.cancel();
      } else {
        final filled = '=' * (progress % (barWidth + 1));
        final empty = ' ' * (barWidth - (progress % (barWidth + 1)));
        final bar = '[$filled$empty]';
        stdout.write('\r${formatOutput(bar)}');
        progress++;
      }
    });
  }
}
