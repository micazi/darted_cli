import 'dart:io';

import '../../console/helper/console.helper.dart';
import '../../console/models/styling/colors.enum.dart';
import '../../console/models/styling/styling_extension.dart';
import '../models/darted_argument.model.dart';
import '../models/darted_command.model.dart';
import '../models/darted_flag.model.dart';
import '../validation/validation_result.dart';
import 'config_generator.dart';

/// Creates the built-in [DartedCommand] for `generate-sample-config`.
DartedCommand createGenerateSampleConfigCommand({
  required List<DartedCommand> commandsTree,
  String? toolName,
  String defaultPath = 'config.yaml',
}) {
  return DartedCommand(
    name: 'generate-sample-config',
    helperDescription:
        'Generates a complete sample configuration file from the registered command tree.',
    isConfigurableInFile: false,
    arguments: [
      DartedArgument(
        name: 'output',
        abbreviation: 'o',
        defaultValue: defaultPath,
        description: 'Output path for the generated sample configuration file.',
        isConfigurableInFile: false,
      ),
    ],
    flags: [
      DartedFlag(
        name: 'force',
        abbreviation: 'f',
        description: 'Force overwrite if the output file already exists.',
        isConfigurableInFile: false,
      ),
    ],
    callback: (arguments, flags) async {
      final outputPath = arguments?['output']?.toString() ?? defaultPath;
      final force = flags?['force'] ?? false;

      final file = File(outputPath);
      if (file.existsSync() && !force) {
        throw ConfigException(
          'File "$outputPath" already exists. Use --force or -f to overwrite.',
        );
      }

      final generator = ConfigGenerator(commandsTree);
      final yamlContent = generator.generate(toolName: toolName);

      // Ensure directory exists if path contains directories
      final parentDir = file.parent;
      if (!parentDir.existsSync()) {
        parentDir.createSync(recursive: true);
      }

      await file.writeAsString(yamlContent);
      ConsoleHelper.write(
        '${'Sample configuration successfully generated at: '.withColor(ConsoleColor.green)}$outputPath\n',
      );
      return 'Sample configuration successfully generated at: $outputPath';
    },
  );
}
