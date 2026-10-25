import 'dart:io';
import 'package:yaml/yaml.dart';
import '../../console/helper/console.helper.dart';
import '../../console/models/console_models.exports.dart';
import '../models/darted_argument.model.dart';
import '../models/darted_command.model.dart';
import '../models/darted_flag.model.dart';

/// Generates formatted, stylized help and version messages from command trees.
class HelpGenerator {
  const HelpGenerator();

  /// Attempts to discover package metadata from pubspec.yaml in current or parent dirs.
  static (String name, String version) getPackageMetadata() {
    try {
      var dir = Directory.current;
      for (var i = 0; i < 4; i++) {
        final pubspecFile =
            File('${dir.path}${Platform.pathSeparator}pubspec.yaml');
        if (pubspecFile.existsSync()) {
          final content = loadYaml(pubspecFile.readAsStringSync());
          if (content is YamlMap) {
            final name = content['name']?.toString() ?? 'darted';
            final version = content['version']?.toString() ?? '1.0.0';
            return (name, version);
          }
        }
        final parent = dir.parent;
        if (parent.path == dir.path) break;
        dir = parent;
      }
    } catch (_) {
      // Fallback if unable to read pubspec
    }
    return ('darted', '1.0.0');
  }

  /// Generates the root-level help message showing all top-level commands and options.
  String generateRootHelp(List<DartedCommand> commandsTree) {
    final meta = getPackageMetadata();
    final packageName = meta.$1;

    final commandRows = <String, String>{};
    for (final cmd in commandsTree) {
      commandRows[cmd.name] =
          cmd.helperDescription ?? 'N/A'.withColor(ConsoleColor.lightRed);
    }

    final justifiedCommands = commandRows.isNotEmpty
        ? ConsoleHelper.justifyMap(commandRows, gapSeparatorSize: 4)
            .reduce((a, b) => "$a\n| $b")
        : 'N/A'.withColor(ConsoleColor.lightRed);

    final flagRows = <String, String>{
      '--help, -h': 'Show this help message.',
      '--version, -v': 'Show installed version.',
    };

    final justifiedFlags =
        ConsoleHelper.justifyMap(flagRows, gapSeparatorSize: 4)
            .reduce((a, b) => "$a\n| $b");

    return """
|======
|
| ${packageName.withColor(ConsoleColor.lightMagenta).withTextStyle(ConsoleTextModifier.bold)}
|
| ${'Usage:'.withColor(ConsoleColor.cyan)} $packageName <command> [arguments] [flags]
|
| ${'Available Commands:'.withColor(ConsoleColor.yellow)}
| $justifiedCommands
|
| ${'Global Flags:'.withColor(ConsoleColor.yellow)}
| $justifiedFlags
|
|======
""";
  }

  /// Generates a subcommand-specific help message for [command].
  String generateCommandHelp(
    DartedCommand command, {
    List<DartedCommand>? commandPath,
  }) {
    final meta = getPackageMetadata();
    final packageName = meta.$1;

    final pathStr = (commandPath != null && commandPath.isNotEmpty)
        ? commandPath.map((c) => c.name).join(' ')
        : command.name;

    final positionalArgs = (command.arguments ?? [])
        .whereType<DartedArgument>()
        .where((a) => a.isMainReq)
        .map((a) => '<${a.name}>')
        .join(' ');

    final usage =
        'Usage: $packageName $pathStr ${positionalArgs.isNotEmpty ? '$positionalArgs ' : ''}[--arguments] [--flags]';
    final helpDescription =
        '${command.name.withColor(ConsoleColor.cyan)} :- ${command.helperDescription ?? 'N/A'}';

    // Format arguments
    final argRows = <String, String>{};
    for (final arg in (command.arguments ?? []).whereType<DartedArgument>()) {
      final key =
          '--${arg.name},-${arg.abbreviation} [default: ${arg.defaultValue ?? 'N/A'}]';
      final desc = arg.description?.withColor(ConsoleColor.grey) ?? '';
      argRows[key] = desc;
    }

    final justifiedArgs = argRows.isNotEmpty
        ? ConsoleHelper.justifyMap(argRows, gapSeparatorSize: 4)
            .reduce((a, b) => "$a\n| $b")
        : 'N/A'.withColor(ConsoleColor.lightRed);

    // Format flags
    final allFlags = [
      ...?command.flags,
      DartedFlag.help,
      DartedFlag.version,
    ];

    final flagRows = <String, String>{};
    for (final f in allFlags) {
      final key = '--${f.name},-${f.abbreviation}'
          '${f.canBeNegated ? ' (Negatable)'.withColor(ConsoleColor.magenta) : ''}'
          '${f.appliedByDefault ? ' (Applied by default)'.withColor(ConsoleColor.cyan) : ''}';
      final desc = f.description?.withColor(ConsoleColor.grey) ?? '';
      flagRows[key] = desc;
    }

    final justifiedFlags = flagRows.isNotEmpty
        ? ConsoleHelper.justifyMap(flagRows, gapSeparatorSize: 4)
            .reduce((a, b) => "$a\n| $b")
        : 'N/A'.withColor(ConsoleColor.lightRed);

    // Format subcommands
    final subCmdRows = <String, String>{};
    for (final sub in (command.subCommands ?? [])) {
      subCmdRows[sub.name] =
          sub.helperDescription ?? 'N/A'.withColor(ConsoleColor.lightRed);
    }

    final justifiedSubCommands = subCmdRows.isNotEmpty
        ? ConsoleHelper.justifyMap(subCmdRows, gapSeparatorSize: 4)
            .reduce((a, b) => "$a\n| $b")
        : 'N/A'.withColor(ConsoleColor.lightRed);

    return """
|======
|
| $helpDescription
|
| $usage
|
| ${'Available Arguments:'.withColor(ConsoleColor.yellow)}
| $justifiedArgs
|
| ${'Available Flags:'.withColor(ConsoleColor.yellow)}
| $justifiedFlags
|
| ${'Available Sub-commands:'.withColor(ConsoleColor.yellow)}
| $justifiedSubCommands
|
|======
""";
  }

  /// Generates the standard version message.
  String generateVersionMessage() {
    final meta = getPackageMetadata();
    final packageName = meta.$1;
    final version = meta.$2;

    return """
|-------
|
| ${packageName.withColor(ConsoleColor.lightMagenta).withTextStyle(ConsoleTextModifier.underline)}
|
| Current installed version: $version
|
|-------
""";
  }
}
