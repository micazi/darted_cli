import 'loader_base.dart';

class SpinnerLoader extends BaseLoader {
  SpinnerLoader({
    super.task,
    super.interval,
    super.completionSymbol,
  });

  @override
  void animate() {
    start(); // Starts the spinner animation
  }
}
