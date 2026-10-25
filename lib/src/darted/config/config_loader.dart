import 'dart:io';

import 'package:yaml/yaml.dart';

import '../models/darted_argument.model.dart';
import '../models/darted_command.model.dart';
import '../validation/validation_result.dart';

/// Loads and validates configuration files (YAML/JSON) against a [commandsTree].
class ConfigLoader {
  final List<DartedCommand> commandsTree;

  const ConfigLoader(this.commandsTree);

  /// Loads configuration from [path].
  ///
  /// If [mustExist] is `true` and the file is missing, throws [ConfigException].
  /// If [mustExist] is `false` and the file is missing, returns an empty map.
  Map<String, dynamic> loadFile(String path, {bool mustExist = true}) {
    final file = File(path);
    if (!file.existsSync()) {
      if (mustExist) {
        throw ConfigException('Configuration file not found at: $path');
      }
      return {};
    }

    String content;
    try {
      content = file.readAsStringSync();
    } catch (e) {
      throw ConfigException('Could not read configuration file at "$path": $e');
    }

    return loadString(content, sourcePath: path);
  }

  /// Parses and validates a configuration string against the [commandsTree].
  Map<String, dynamic> loadString(String content, {String? sourcePath}) {
    if (content.trim().isEmpty) {
      return {};
    }

    dynamic yamlData;
    try {
      yamlData = loadYaml(content,
          sourceUrl: sourcePath != null ? Uri.file(sourcePath) : null);
    } catch (e) {
      throw ConfigException(
        'Failed to parse configuration file'
        '${sourcePath != null ? ' at "$sourcePath"' : ''}: $e',
      );
    }

    if (yamlData == null) {
      return {};
    }

    if (yamlData is! Map) {
      throw const ConfigException(
        'Configuration file must contain a key-value mapping at the root level.',
      );
    }

    final nativeMap = _deepConvert(yamlData);
    validate(nativeMap);
    return nativeMap;
  }

  /// Validates the structure and keys of [config] against [commandsTree].
  void validate(Map<String, dynamic> config) {
    _validateCommands(config, commandsTree, parentPath: '');
  }

  void _validateCommands(
    Map<String, dynamic> currentConfig,
    List<DartedCommand> availableCommands, {
    required String parentPath,
  }) {
    for (final entry in currentConfig.entries) {
      final key = entry.key;
      final value = entry.value;

      final matchedCommand = availableCommands
          .where((c) => c.name.toLowerCase() == key.toLowerCase())
          .firstOrNull;

      if (matchedCommand == null) {
        final pathDisplay = parentPath.isEmpty ? key : '$parentPath.$key';
        throw ConfigException(
          'Unknown command or configuration section "$pathDisplay".',
        );
      }

      if (!matchedCommand.isConfigurableInFile) {
        final pathDisplay = parentPath.isEmpty ? key : '$parentPath.$key';
        throw ConfigException(
          'Command "$pathDisplay" is not configurable in configuration files.',
        );
      }

      if (value is! Map) {
        final pathDisplay = parentPath.isEmpty ? key : '$parentPath.$key';
        throw ConfigException(
          'Configuration for command "$pathDisplay" must be a key-value section.',
        );
      }

      _validateCommandOptions(
        value as Map<String, dynamic>,
        matchedCommand,
        commandPath: parentPath.isEmpty
            ? matchedCommand.name
            : '$parentPath.${matchedCommand.name}',
      );
    }
  }

  void _validateCommandOptions(
    Map<String, dynamic> commandConfig,
    DartedCommand command, {
    required String commandPath,
  }) {
    final availableArgs =
        (command.arguments ?? []).whereType<DartedArgument>().toList();
    final availableFlags = command.flags ?? [];
    final availableSubs = command.subCommands ?? [];

    for (final entry in commandConfig.entries) {
      final key = entry.key;
      final value = entry.value;

      // Check if it's a subcommand
      final matchedSub = availableSubs
          .where((s) => s.name.toLowerCase() == key.toLowerCase())
          .firstOrNull;

      if (matchedSub != null) {
        if (!matchedSub.isConfigurableInFile) {
          throw ConfigException(
            'Subcommand "$commandPath.$key" is not configurable in configuration files.',
          );
        }
        if (value is! Map) {
          throw ConfigException(
            'Section for subcommand "$commandPath.$key" must be a key-value mapping.',
          );
        }
        _validateCommandOptions(
          value as Map<String, dynamic>,
          matchedSub,
          commandPath: '$commandPath.$key',
        );
        continue;
      }

      // Check if it's an argument
      final matchedArg = availableArgs
          .where((a) => a.name.toLowerCase() == key.toLowerCase())
          .firstOrNull;

      if (matchedArg != null) {
        if (!matchedArg.isConfigurableInFile) {
          throw ConfigException(
            'Argument "$commandPath.$key" is not configurable in configuration files.',
          );
        }
        _validateArgumentValue(matchedArg, value, commandPath: commandPath);
        continue;
      }

      // Check if it's a flag
      final matchedFlag = availableFlags
          .where((f) => f.name.toLowerCase() == key.toLowerCase())
          .firstOrNull;

      if (matchedFlag != null) {
        if (!matchedFlag.isConfigurableInFile) {
          throw ConfigException(
            'Flag "$commandPath.$key" is not configurable in configuration files.',
          );
        }
        if (value is! bool && value is! String) {
          throw ConfigException(
            'Flag "$commandPath.$key" must be a boolean (true/false).',
          );
        }
        continue;
      }

      throw ConfigException(
        'Unknown option "$key" under command "$commandPath".',
      );
    }
  }

  void _validateArgumentValue(
    DartedArgument arg,
    dynamic value, {
    required String commandPath,
  }) {
    if (value == null) return;

    if (arg.isMultiOption) {
      List<dynamic> items;
      if (value is List) {
        items = value;
      } else if (value is String) {
        items = value
            .split(arg.optionsSeparator ?? ',')
            .map((s) => s.trim())
            .toList();
      } else {
        throw ConfigException(
          'Argument "$commandPath.${arg.name}" expects a list or delimited string.',
        );
      }

      if (arg.acceptedMultiOptionValues != null &&
          arg.acceptedMultiOptionValues!.isNotEmpty) {
        final accepted = arg.acceptedMultiOptionValues!
            .split(arg.optionsSeparator ?? ',')
            .map((s) => s.trim().toLowerCase())
            .toSet();

        for (final item in items) {
          final strItem = item.toString().trim();
          if (!accepted.contains(strItem.toLowerCase())) {
            throw ConfigException(
              'Invalid value "$strItem" for argument "$commandPath.${arg.name}". '
              'Accepted values are: ${arg.acceptedMultiOptionValues}.',
            );
          }
        }
      }
    } else {
      if (value is List || value is Map) {
        throw ConfigException(
          'Argument "$commandPath.${arg.name}" expects a scalar value, got ${value.runtimeType}.',
        );
      }

      if (arg.acceptedMultiOptionValues != null &&
          arg.acceptedMultiOptionValues!.isNotEmpty) {
        final accepted = arg.acceptedMultiOptionValues!
            .split(arg.optionsSeparator ?? ',')
            .map((s) => s.trim().toLowerCase())
            .toSet();

        final strVal = value.toString().trim();
        if (!accepted.contains(strVal.toLowerCase())) {
          throw ConfigException(
            'Invalid value "$strVal" for argument "$commandPath.${arg.name}". '
            'Accepted values are: ${arg.acceptedMultiOptionValues}.',
          );
        }
      }
    }
  }

  /// Extracts the configuration section specifically targeting [commandPath].
  Map<String, dynamic> extractSectionForPath(
    Map<String, dynamic> config,
    List<String> commandPath,
  ) {
    var current = config;
    for (final seg in commandPath) {
      final matchKey = current.keys
          .where((k) => k.toLowerCase() == seg.toLowerCase())
          .firstOrNull;

      if (matchKey == null) {
        return {};
      }

      final val = current[matchKey];
      if (val is Map<String, dynamic>) {
        current = val;
      } else {
        return {};
      }
    }
    return current;
  }

  Map<String, dynamic> _deepConvert(Map input) {
    final result = <String, dynamic>{};
    for (final entry in input.entries) {
      final key = entry.key.toString();
      final val = entry.value;
      if (val is Map) {
        result[key] = _deepConvert(val);
      } else if (val is List) {
        result[key] = _deepConvertList(val);
      } else {
        result[key] = val;
      }
    }
    return result;
  }

  List<dynamic> _deepConvertList(List input) {
    return input.map((item) {
      if (item is Map) {
        return _deepConvert(item);
      } else if (item is List) {
        return _deepConvertList(item);
      }
      return item;
    }).toList();
  }
}
