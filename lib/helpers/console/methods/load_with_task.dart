import '../../../models/console/loading/loader_position.enum.dart';

import '../../../models/console/styling/colors.enum.dart';
import '../../../models/console/loading/console_loader.enum.dart';
import '../../../models/console/loading/loader_base.dart';

/// Supply a task and a process future for that task, and show a beautiful loader till the task is finished. You can also customize a replacement output when it's done.
Future<void> loadWithTaskImpl({
  required String task,
  required Future Function() process,
  //
  required ConsoleLoader loader,
  required ConsoleColor loaderColor,
  required Duration loaderSpeed,
  required LoaderPosition loaderPosition,
  required String loaderSuccessReplacement,
  //
  ConsoleLoaderBase? customLoader,
}) async {
  ConsoleLoaderBase cLoader = customLoader ?? loader.base(task, animationColor: loaderColor, animationSpeed: loaderSpeed, animationPosition: loaderPosition);
  await cLoader.start();
  await process();
  await cLoader.stop(completionSymbol: loaderSuccessReplacement);
}
