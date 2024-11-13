import 'package:darted_cli/models/console/styling/colors.enum.dart';
import 'package:darted_cli/models/console/loading/loader_base.dart';
import 'package:darted_cli/loaders/progress_bar.loader.dart';
import 'package:darted_cli/loaders/spinner.loader.dart';

import 'loader_position.enum.dart';

enum ConsoleLoader { spinner, progressBar }

extension ConsoleLoaderExtension on ConsoleLoader {
  ConsoleLoaderBase base(
    String task, {
    ConsoleColor? animationColor = ConsoleColor.cyan,
    Duration? animationSpeed = const Duration(milliseconds: 100),
    LoaderPosition? animationPosition = LoaderPosition.after,
  }) {
    switch (this) {
      case ConsoleLoader.spinner:
        return SpinnerLoader(task: task, animationColor: animationColor!, speed: animationSpeed!, animationPosition: animationPosition!);
      case ConsoleLoader.progressBar:
        return ProgressBarLoader(task: task, animationColor: animationColor!, speed: animationSpeed!, animationPosition: animationPosition!);
      //
      default:
        return SpinnerLoader(task: task, animationColor: animationColor!, speed: animationSpeed!, animationPosition: animationPosition!);
    }
  }
}
