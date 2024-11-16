import 'package:darted_cli/helpers/darted/prints/darted_title.dart';
import 'package:darted_cli/helpers/darted/prints/stable_points.dart';
import 'package:darted_cli/helpers/style_extension.helper.dart';

String dartedHelper = """
| ${'darted_cli'.withColor(ConsoleColor.magenta).withTextStyle(ConsoleTextModifier.bold)} is a customizable Dart CLI framework for building command-line tools with hierarchical command structures, argument parsing, and flag management. 
""";

String dartedUsage = """
| Usage: darted_cli
""";

String dartedMainPrint = startPrint + dartedTitle.withColor(ConsoleColor.lightCyan) + dartedHelper + endPrint;
