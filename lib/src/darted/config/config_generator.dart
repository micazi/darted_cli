import '../models/darted_argument.model.dart';
import '../models/darted_command.model.dart';
import '../models/darted_flag.model.dart';

/// Generates a sample YAML configuration string from a registered [commandsTree].
class ConfigGenerator {
  final List<DartedCommand> commandsTree;

  const ConfigGenerator(this.commandsTree);

  /// Generates the complete sample YAML configuration.
  String generate({String? toolName}) {
    final buffer = StringBuffer();

    buffer
        .writeln('# ========================================================');
    if (toolName != null && toolName.isNotEmpty) {
      buffer.writeln('# Sample Configuration File for $toolName');
    } else {
      buffer.writeln('# Sample Configuration File');
    }
    buffer.writeln('# Generated automatically by generate-sample-config');
    buffer
        .writeln('# ========================================================');
    buffer.writeln();

    final eligibleCommands =
        commandsTree.where((c) => c.isConfigurableInFile).toList();

    for (var i = 0; i < eligibleCommands.length; i++) {
      _writeCommand(buffer, eligibleCommands[i], depth: 0);
      if (i < eligibleCommands.length - 1) {
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  void _writeCommand(StringBuffer buffer, DartedCommand command,
      {required int depth}) {
    final indent = '  ' * depth;

    if (command.helperDescription != null &&
        command.helperDescription!.isNotEmpty) {
      buffer.writeln('$indent# ${command.helperDescription}');
    }

    final eligibleArgs = (command.arguments ?? [])
        .whereType<DartedArgument>()
        .where((a) => a.isConfigurableInFile)
        .toList();

    final eligibleFlags =
        (command.flags ?? []).where((f) => f.isConfigurableInFile).toList();

    final eligibleSubs = (command.subCommands ?? [])
        .where((c) => c.isConfigurableInFile)
        .toList();

    final hasContent = eligibleArgs.isNotEmpty ||
        eligibleFlags.isNotEmpty ||
        eligibleSubs.isNotEmpty;

    if (!hasContent) {
      buffer.writeln('$indent${command.name}: {}');
      return;
    }

    buffer.writeln('$indent${command.name}:');

    // 1. Arguments
    for (final arg in eligibleArgs) {
      _writeArgument(buffer, arg, depth: depth + 1);
    }

    // 2. Flags
    for (final flag in eligibleFlags) {
      _writeFlag(buffer, flag, depth: depth + 1);
    }

    // 3. Subcommands
    for (final sub in eligibleSubs) {
      buffer.writeln();
      _writeCommand(buffer, sub, depth: depth + 1);
    }
  }

  void _writeArgument(StringBuffer buffer, DartedArgument arg,
      {required int depth}) {
    final indent = '  ' * depth;

    if (arg.description != null && arg.description!.isNotEmpty) {
      buffer.writeln('$indent# ${arg.description}');
    }

    if (arg.acceptedMultiOptionValues != null &&
        arg.acceptedMultiOptionValues!.isNotEmpty) {
      final acceptedList = arg.acceptedMultiOptionValues!
          .split(arg.optionsSeparator ?? ',')
          .map((v) => v.trim())
          .join(', ');
      buffer.writeln('$indent# Accepted values: [$acceptedList]');
    }

    if (arg.isMainReq) {
      buffer.writeln('$indent# Required');
    }

    if (arg.isMultiOption) {
      if (arg.defaultValue != null && arg.defaultValue!.isNotEmpty) {
        final sep = arg.optionsSeparator ?? ',';
        final items =
            arg.defaultValue!.split(sep).map((s) => s.trim()).toList();
        buffer.writeln('$indent# Default: [${items.join(', ')}]');
        buffer.writeln('$indent${arg.name}:');
        for (final item in items) {
          buffer.writeln('$indent  - ${_formatScalar(item)}');
        }
      } else {
        buffer.writeln('$indent${arg.name}: []');
      }
    } else {
      if (arg.defaultValue != null) {
        buffer.writeln('$indent# Default: ${arg.defaultValue}');
        buffer
            .writeln('$indent${arg.name}: ${_formatScalar(arg.defaultValue!)}');
      } else {
        buffer.writeln('$indent${arg.name}: ""');
      }
    }
  }

  void _writeFlag(StringBuffer buffer, DartedFlag flag, {required int depth}) {
    final indent = '  ' * depth;

    if (flag.description != null && flag.description!.isNotEmpty) {
      buffer.writeln('$indent# ${flag.description}');
    }
    buffer.writeln('$indent# Default: ${flag.appliedByDefault}');
    buffer.writeln('$indent${flag.name}: ${flag.appliedByDefault}');
  }

  String _formatScalar(String value) {
    if (int.tryParse(value) != null || double.tryParse(value) != null) {
      return value;
    }
    if (value.toLowerCase() == 'true' || value.toLowerCase() == 'false') {
      return value.toLowerCase();
    }
    if (value.contains(':') ||
        value.contains('#') ||
        value.contains('[') ||
        value.contains(']') ||
        value.contains('{') ||
        value.contains('}') ||
        value.contains(',') ||
        value.startsWith(' ') ||
        value.endsWith(' ')) {
      return '"${value.replaceAll('"', '\\"')}"';
    }
    return value;
  }
}
