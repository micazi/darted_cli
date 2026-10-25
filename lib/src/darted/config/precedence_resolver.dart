import '../models/darted_argument.model.dart';
import '../models/darted_command.model.dart';
import '../models/darted_flag.model.dart';
import '../validation/validation_result.dart';
import 'config_loader.dart';
import 'env_resolver.dart';

/// Result of applying unified precedence resolution.
class ResolvedPrecedenceResult {
  final Map<String, dynamic> arguments;
  final Map<String, bool> flags;

  const ResolvedPrecedenceResult({
    required this.arguments,
    required this.flags,
  });
}

/// Applies unified 4-tier precedence resolution across:
/// 1. Explicit CLI arguments and flags
/// 2. Process environment variables
/// 3. Configuration file values
/// 4. Declared defaults
class PrecedenceResolver {
  final Map<String, dynamic>? configData;
  final Map<String, String>? environment;

  const PrecedenceResolver({
    this.configData,
    this.environment,
  });

  /// Resolves the final arguments and flags for [command] along [commandPath].
  ResolvedPrecedenceResult resolve({
    required DartedCommand command,
    required List<String> commandPath,
    required Map<String, dynamic> explicitCliArguments,
    required Map<String, bool> explicitCliFlags,
    required List<String> positionals,
    bool isHelpOrVersion = false,
  }) {
    final finalArgs = <String, dynamic>{};
    final finalFlags = <String, bool>{};

    final availableArgs =
        (command.arguments ?? []).whereType<DartedArgument>().toList();
    final availableFlags = [
      DartedFlag.help,
      DartedFlag.version,
      ...?command.flags,
    ];

    // 1. Resolve Environment Variables
    final envResolver = EnvResolver(environment);
    final envArgs = envResolver.resolveArguments(command);
    final envFlags = envResolver.resolveFlags(command);

    // 2. Resolve Config File Section
    Map<String, dynamic> configSection = {};
    if (configData != null && configData!.isNotEmpty) {
      final loader = ConfigLoader([command]);
      configSection = loader.extractSectionForPath(configData!, commandPath);
    }

    // --- FLAGS PRECEDENCE ---
    for (final flag in availableFlags) {
      // 1. Explicit CLI flag
      if (explicitCliFlags.containsKey(flag.name)) {
        finalFlags[flag.name] = explicitCliFlags[flag.name]!;
        continue;
      }

      // 2. Environment variable
      if (envFlags.containsKey(flag.name)) {
        finalFlags[flag.name] = envFlags[flag.name]!;
        continue;
      }

      // 3. Configuration file value (only if isConfigurableInFile)
      if (flag.isConfigurableInFile && configSection.containsKey(flag.name)) {
        final rawVal = configSection[flag.name];
        if (rawVal is bool) {
          finalFlags[flag.name] = rawVal;
          continue;
        } else if (rawVal is String) {
          final lower = rawVal.trim().toLowerCase();
          if (lower == 'true' || lower == '1' || lower == 'yes') {
            finalFlags[flag.name] = true;
            continue;
          } else if (lower == 'false' || lower == '0' || lower == 'no') {
            finalFlags[flag.name] = false;
            continue;
          }
        }
      }

      // 4. Declared default
      if (flag.appliedByDefault) {
        finalFlags[flag.name] = true;
      }
    }

    // --- ARGUMENTS PRECEDENCE ---
    // First map positionals to declared positional arguments (highest CLI priority)
    final positionalArgDefs = availableArgs.where((a) => a.isMainReq).toList();
    final positionalMapped = <String, dynamic>{};
    for (var p = 0; p < positionalArgDefs.length; p++) {
      final def = positionalArgDefs[p];
      if (p < positionals.length) {
        positionalMapped[def.name] = positionals[p];
      }
    }

    for (final arg in availableArgs) {
      // 1. Explicit CLI argument or positional
      if (positionalMapped.containsKey(arg.name)) {
        finalArgs[arg.name] = positionalMapped[arg.name];
        continue;
      }
      if (explicitCliArguments.containsKey(arg.name)) {
        finalArgs[arg.name] = explicitCliArguments[arg.name];
        continue;
      }

      // 2. Environment variable
      if (envArgs.containsKey(arg.name)) {
        finalArgs[arg.name] = envArgs[arg.name];
        continue;
      }

      // 3. Configuration file value (only if isConfigurableInFile)
      if (arg.isConfigurableInFile && configSection.containsKey(arg.name)) {
        final configVal = configSection[arg.name];
        if (configVal != null) {
          finalArgs[arg.name] = configVal;
          continue;
        }
      }

      // 4. Declared default
      if (arg.defaultValue != null) {
        finalArgs[arg.name] = arg.defaultValue;
      }
    }

    // --- VALIDATION OF FINAL RESOLVED VALUES ---
    if (!isHelpOrVersion) {
      // Validate required arguments
      for (final def in positionalArgDefs) {
        if (!finalArgs.containsKey(def.name) || finalArgs[def.name] == null) {
          throw MissingRequiredArgumentException(
            def.name,
            command: command.name,
            isPositional: true,
          );
        }
      }

      // Validate acceptedMultiOptionValues on resolved arguments
      for (final arg in availableArgs) {
        if (finalArgs.containsKey(arg.name)) {
          final dynamic rawVal = finalArgs[arg.name];
          if (rawVal != null && arg.acceptedMultiOptionValues != null) {
            final sep = arg.optionsSeparator ?? ',';
            final accepted = arg.acceptedMultiOptionValues!
                .split(sep)
                .map((s) => s.trim().toLowerCase())
                .where((s) => s.isNotEmpty)
                .toList();

            final passedValues = rawVal is List
                ? rawVal.map((e) => e.toString().trim()).toList()
                : rawVal.toString().split(sep).map((s) => s.trim()).toList();

            for (final v in passedValues) {
              if (!accepted.contains(v.toLowerCase())) {
                throw InvalidOptionValueException(
                  arg.name,
                  v,
                  command: command.name,
                  acceptedValues: arg.acceptedMultiOptionValues!
                      .split(sep)
                      .map((s) => s.trim())
                      .toList(),
                );
              }
            }
          }
        }
      }
    }

    return ResolvedPrecedenceResult(
      arguments: finalArgs,
      flags: finalFlags,
    );
  }
}
