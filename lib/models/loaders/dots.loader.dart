import 'loader_base.dart';

class DotsLoader extends BaseLoader {
  final int maxDots;

  DotsLoader({
    super.task,
    super.interval = const Duration(milliseconds: 250),
    super.completionSymbol,
    this.maxDots = 3,
  });

  @override
  void animate() {
    start();
  }

  // @override
  // void start() {
  //   int dotCount = 0;
  //   _isLoading = true;
  //   _timer = Timer.periodic(interval, (timer) {
  //     if (_isLoading) {
  //       stdout.write('\r${'.' * (dotCount % (maxDots + 1))} $task...');
  //       dotCount++;
  //     } else {
  //       timer.cancel();
  //     }
  //   });
  // }
}
