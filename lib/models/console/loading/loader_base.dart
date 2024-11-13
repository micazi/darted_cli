import 'dart:io';
import 'package:darted_cli/helpers/style_extension.helper.dart';
import 'package:darted_cli/models/console/styling/colors.enum.dart';

import 'loader_position.enum.dart';

abstract class ConsoleLoaderBase {
  String? task;
  final Duration speed;
  final LoaderPosition animationPosition;
  final ConsoleColor animationColor;
  bool isLoading = false;

  ConsoleLoaderBase({
    this.task,
    this.speed = const Duration(milliseconds: 100),
    this.animationPosition = LoaderPosition.after,
    this.animationColor = ConsoleColor.cyan,
  });

  Future<void> start();

  Future<void> stop({String? completionSymbol = '✓'}) async {
    isLoading = false;

    // Clear the current line to remove any leftover characters
    stdout.write('\r\x1B[2K'); // '\x1B[2K' clears the line

    // Print the final message with the check mark and task
    if (animationPosition == LoaderPosition.before) {
      stdout.write('$completionSymbol $task\n');
    } else {
      stdout.write('$task $completionSymbol\n');
    }
  }

  // Helper method to display the animation and task in the correct order
  String formatOutput(String animation) {
    return animationPosition == LoaderPosition.before ? '${animation.withColor(animationColor)} $task' : '$task ${animation.withColor(animationColor)}';
  }
}
