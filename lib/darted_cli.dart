import 'console_helper.dart';
import 'src/darted/models/darted_models.exports.dart';
import 'src/darted/helper/darted.helper.dart';
//
export 'src/darted/models/darted_models.exports.dart';
export 'src/darted/helper/darted.helper.dart';
export 'src/darted/parser/cli_token.dart';
export 'src/darted/parser/cli_tokenizer.dart';
export 'src/darted/parser/command_resolver.dart';
export 'src/darted/parser/parsed_command_result.dart';
export 'src/darted/validation/validation_result.dart';
export 'src/darted/execution/darted_execution_result.dart';
export 'src/darted/help/help_generator.dart';
export 'src/darted/config/config_generator.dart';
export 'src/darted/config/generate_sample_config_command.dart';
export 'src/darted/config/config_loader.dart';
export 'src/darted/config/env_resolver.dart';
export 'src/darted/config/precedence_resolver.dart';

import 'src/darted/config/config_loader.dart';
import 'src/darted/config/generate_sample_config_command.dart';
import 'src/darted/execution/darted_execution_result.dart';
import 'src/darted/help/help_generator.dart';
import 'src/darted/parser/command_resolver.dart';
import 'src/darted/validation/validation_result.dart';
import 'src/darted/constants/print_constants.dart';

/// Programmatically executes the given CLI [input] against [commandsTree].
///
/// Unlike [dartedEntry], this function returns a [DartedExecutionResult] instead
/// of calling `exit()` on failures, allowing safe use in automated tests and
/// embedded applications. Set [throwOnError] to `true` to rethrow exceptions.
Future<DartedExecutionResult> dartedExecute({
  required List<DartedCommand> commandsTree,
  required List<String> input,
  // Configuration File Customizations
  bool generateSampleConfig = false,
  String? sampleConfigPath,
  String? sampleConfigToolName,
  String? configPath,
  bool configMustExist = false,
  Map<String, dynamic>? configData,
  // Environment Variables Customizations
  Map<String, String>? environment,
  // Validation Customizations
  Future<String> Function(List<DartedCommand> commandsTree)? customEntryHelper,
  String Function(String, String?)? customCommandInvalidError,
  String Function(String, Map<String, dynamic>, String?)?
      customArgumentInvalidError,
  String Function(String, Map<String, dynamic>, List<String>)?
      customArgumentOptionsInvalidError,
  String Function(String, Map<String, bool>)? customFlagInvalidError,
  String Function(String, Map<String, bool>)? customFlagNegatedError,
  // Responses Customizations
  String Function(DartedCommand)? customHelpResponse,
  String Function()? customVersionResponse,
  bool throwOnError = false,
}) async {
  final effectiveTree = List<DartedCommand>.from(commandsTree);
  if (generateSampleConfig) {
    final alreadyExists =
        effectiveTree.any((c) => c.name == 'generate-sample-config');
    if (!alreadyExists) {
      effectiveTree.add(
        createGenerateSampleConfigCommand(
          commandsTree: commandsTree,
          toolName: sampleConfigToolName,
          defaultPath: sampleConfigPath ?? 'config.yaml',
        ),
      );
    }
  }

  const helpGen = HelpGenerator();

  // 1. Root Help / Version checks or empty input
  if (input.isEmpty) {
    final entryMsg = await customEntryHelper?.call(effectiveTree) ??
        helpGen.generateRootHelp(effectiveTree);
    return DartedExecutionResult.success(message: entryMsg);
  }

  if (input.length == 1) {
    final single = input.first;
    if (single == '-v' || single == '--version') {
      final verMsg =
          customVersionResponse?.call() ?? helpGen.generateVersionMessage();
      return DartedExecutionResult.success(message: verMsg);
    }
    if (single == '-h' || single == '--help') {
      final helpMsg = await customEntryHelper?.call(effectiveTree) ??
          helpGen.generateRootHelp(effectiveTree);
      return DartedExecutionResult.success(message: helpMsg);
    }
  }

  // 2. Parse and resolve against the command tree
  try {
    Map<String, dynamic>? effectiveConfig = configData;
    if (configPath != null && configPath.isNotEmpty) {
      final loader = ConfigLoader(effectiveTree);
      final loaded = loader.loadFile(configPath, mustExist: configMustExist);
      effectiveConfig = {
        ...?effectiveConfig,
        ...loaded,
      };
    }

    final resolver = CommandResolver(
      effectiveTree,
      configData: effectiveConfig,
      environment: environment,
    );
    final resolved = resolver.resolve(input);

    if (resolved == null) {
      final entryMsg = await customEntryHelper?.call(effectiveTree) ??
          helpGen.generateRootHelp(effectiveTree);
      return DartedExecutionResult.success(message: entryMsg);
    }

    // 3. Check for help / version flag on the resolved command
    if (resolved.isHelpRequested) {
      final cmdHelp = customHelpResponse?.call(resolved.command) ??
          helpGen.generateCommandHelp(
            resolved.command,
            commandPath: resolved.commandPath,
          );
      return DartedExecutionResult.success(
        message: cmdHelp,
        parsedCommand: resolved,
      );
    }

    if (resolved.isVersionRequested) {
      final verMsg =
          customVersionResponse?.call() ?? helpGen.generateVersionMessage();
      return DartedExecutionResult.success(
        message: verMsg,
        parsedCommand: resolved,
      );
    }

    // 4. Execute the command callback
    final dynamic cbResult = resolved.command.callback(
      resolved.arguments,
      resolved.flags,
    );
    dynamic awaited = cbResult;
    if (cbResult is Future) {
      awaited = await cbResult;
    }

    return DartedExecutionResult.success(
      parsedCommand: resolved,
      message: awaited is String ? awaited : null,
    );
  } on DartedValidationException catch (e, stackTrace) {
    if (throwOnError) rethrow;

    String? customErrorMsg;
    if (e is UnknownCommandException) {
      customErrorMsg =
          customCommandInvalidError?.call(e.command, e.closestMatch);
    } else if (e is MissingRequiredArgumentException) {
      customErrorMsg = customArgumentInvalidError?.call(
        e.command,
        {e.argumentName: null},
        null,
      );
    } else if (e is InvalidOptionValueException) {
      customErrorMsg = customArgumentOptionsInvalidError?.call(
        e.command,
        {e.option: e.value},
        e.acceptedValues,
      );
    } else if (e is FlagCannotBeNegatedException) {
      customErrorMsg = customFlagNegatedError?.call(
        e.command,
        {e.flagName: false},
      );
    }

    final formattedMsg = customErrorMsg ??
        "$startPrint\n|\n| ${'Error:'.withColor(ConsoleColor.red)} ${e.message}\n|\n$endPrint\n";

    return DartedExecutionResult.failure(
      exitCode: 1,
      message: formattedMsg,
      error: e,
      stackTrace: stackTrace,
    );
  } catch (e, stackTrace) {
    if (throwOnError) rethrow;
    final formattedMsg =
        "$startPrint\n|\n| ${'Error:'.withColor(ConsoleColor.red)} $e\n|\n$endPrint\n";
    return DartedExecutionResult.failure(
      exitCode: 1,
      message: formattedMsg,
      error: e,
      stackTrace: stackTrace,
    );
  }
}

/// The standard CLI entry point for `darted_cli` applications.
///
/// Executes the command tree with the given user [input] arguments.
/// Validation failures and unexpected errors are printed to stdout and
/// terminate the process with exit code 1.
Future<void> dartedEntry({
  required List<DartedCommand> commandsTree,
  required List<String> input,
  // Configuration File Customizations
  bool generateSampleConfig = false,
  String? sampleConfigPath,
  String? sampleConfigToolName,
  String? configPath,
  bool configMustExist = false,
  Map<String, dynamic>? configData,
  // Environment Variables Customizations
  Map<String, String>? environment,
  // Validation Customizations
  Future<String> Function(List<DartedCommand> commandsTree)? customEntryHelper,
  String Function(String, String?)? customCommandInvalidError,
  String Function(String, Map<String, dynamic>, String?)?
      customArgumentInvalidError,
  String Function(String, Map<String, dynamic>, List<String>)?
      customArgumentOptionsInvalidError,
  String Function(String, Map<String, bool>)? customFlagInvalidError,
  String Function(String, Map<String, bool>)? customFlagNegatedError,
  // Responses Customizations
  String Function(DartedCommand)? customHelpResponse,
  String Function()? customVersionResponse,
}) async {
  final result = await dartedExecute(
    commandsTree: commandsTree,
    input: input,
    generateSampleConfig: generateSampleConfig,
    sampleConfigPath: sampleConfigPath,
    sampleConfigToolName: sampleConfigToolName,
    configPath: configPath,
    configMustExist: configMustExist,
    configData: configData,
    environment: environment,
    customEntryHelper: customEntryHelper,
    customCommandInvalidError: customCommandInvalidError,
    customArgumentInvalidError: customArgumentInvalidError,
    customArgumentOptionsInvalidError: customArgumentOptionsInvalidError,
    customFlagInvalidError: customFlagInvalidError,
    customFlagNegatedError: customFlagNegatedError,
    customHelpResponse: customHelpResponse,
    customVersionResponse: customVersionResponse,
    throwOnError: false,
  );

  if (result.message != null && result.message!.isNotEmpty) {
    ConsoleHelper.write(result.message!);
  }

  if (!result.isSuccess) {
    ConsoleHelper.exit(result.exitCode);
  }
}
