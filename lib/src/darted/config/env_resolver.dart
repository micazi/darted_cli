import 'dart:io';

import '../models/darted_argument.model.dart';
import '../models/darted_command.model.dart';
import '../validation/validation_result.dart';

/// Resolves configuration and option values from process environment variables.
class EnvResolver {
  final Map<String, String> environment;

  EnvResolver([Map<String, String>? environment])
      : environment = environment ?? Platform.environment;

  /// Resolves argument values declared for [command] from [environment].
  Map<String, dynamic> resolveArguments(DartedCommand command) {
    final result = <String, dynamic>{};
    final args = (command.arguments ?? []).whereType<DartedArgument>();

    for (final arg in args) {
      final envVar = arg.environmentVariable;
      if (envVar == null || envVar.isEmpty) continue;

      final rawValue = environment[envVar];
      if (rawValue == null || rawValue.trim().isEmpty) continue;

      final trimmed = rawValue.trim();

      if (arg.isMultiOption) {
        final sep = arg.optionsSeparator ?? ',';
        final items = trimmed.split(sep).map((s) => s.trim()).toList();

        if (arg.acceptedMultiOptionValues != null &&
            arg.acceptedMultiOptionValues!.isNotEmpty) {
          final accepted = arg.acceptedMultiOptionValues!
              .split(sep)
              .map((s) => s.trim().toLowerCase())
              .toSet();

          for (final item in items) {
            if (!accepted.contains(item.toLowerCase())) {
              throw InvalidOptionValueException(
                arg.name,
                item,
                command: command.name,
                acceptedValues: arg.acceptedMultiOptionValues!
                    .split(sep)
                    .map((s) => s.trim())
                    .toList(),
              );
            }
          }
        }
        result[arg.name] = items;
      } else {
        if (arg.acceptedMultiOptionValues != null &&
            arg.acceptedMultiOptionValues!.isNotEmpty) {
          final accepted = arg.acceptedMultiOptionValues!
              .split(arg.optionsSeparator ?? ',')
              .map((s) => s.trim().toLowerCase())
              .toSet();

          if (!accepted.contains(trimmed.toLowerCase())) {
            throw InvalidOptionValueException(
              arg.name,
              trimmed,
              command: command.name,
              acceptedValues: arg.acceptedMultiOptionValues!
                  .split(arg.optionsSeparator ?? ',')
                  .map((s) => s.trim())
                  .toList(),
            );
          }
        }
        result[arg.name] = trimmed;
      }
    }

    return result;
  }

  /// Resolves flag values declared for [command] from [environment].
  Map<String, bool> resolveFlags(DartedCommand command) {
    final result = <String, bool>{};
    final flags = command.flags ?? [];

    for (final flag in flags) {
      final envVar = flag.environmentVariable;
      if (envVar == null || envVar.isEmpty) continue;

      final rawValue = environment[envVar];
      if (rawValue == null || rawValue.trim().isEmpty) continue;

      final lower = rawValue.trim().toLowerCase();
      bool? boolVal;

      if (lower == 'true' ||
          lower == '1' ||
          lower == 'yes' ||
          lower == 'y' ||
          lower == 'on') {
        boolVal = true;
      } else if (lower == 'false' ||
          lower == '0' ||
          lower == 'no' ||
          lower == 'n' ||
          lower == 'off') {
        boolVal = false;
      } else {
        throw ConfigException(
          'Invalid boolean value "$rawValue" from environment variable "$envVar" for flag "${flag.name}".',
        );
      }

      if (!boolVal && !flag.canBeNegated && flag.appliedByDefault) {
        throw FlagCannotBeNegatedException(flag.name, command: command.name);
      }

      result[flag.name] = boolVal;
    }

    return result;
  }
}
