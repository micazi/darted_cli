import '../styling/colors.enum.dart';
import 'loader_base.dart';
import '../../loaders/progress_bar.loader.dart';
import '../../loaders/spinner.loader.dart';

import 'loader_position.enum.dart';

enum ConsoleLoader { spinner, progressBar }

extension ConsoleLoaderExtension on ConsoleLoader {
  ConsoleLoaderBase base(
    String task, {
    ConsoleColor? animationColor,
    Duration? animationSpeed,
    LoaderPosition? animationPosition,
  }) {
    switch (this) {
      case ConsoleLoader.spinner:
        return SpinnerLoader(
            task: task,
            animationColor: animationColor,
            speed: animationSpeed,
            animationPosition: animationPosition);
      case ConsoleLoader.progressBar:
        return ProgressBarLoader(
            task: task,
            animationColor: animationColor!,
            speed: animationSpeed!,
            animationPosition: animationPosition!);
      //
      default:
        return SpinnerLoader(
            task: task,
            animationColor: animationColor!,
            speed: animationSpeed!,
            animationPosition: animationPosition!);
    }
  }
}
