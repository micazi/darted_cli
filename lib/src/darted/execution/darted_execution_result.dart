import '../parser/parsed_command_result.dart';

/// Represents the result of executing a command or CLI lifecycle via `darted_cli`.
class DartedExecutionResult {
  /// The process exit code (0 for success, non-zero for failure).
  final int exitCode;

  /// Whether the command execution succeeded without errors.
  bool get isSuccess => exitCode == 0;

  /// Optional message produced during execution (e.g. help or error text).
  final String? message;

  /// The error object if execution or validation failed.
  final Object? error;

  /// The stack trace associated with [error], if available.
  final StackTrace? stackTrace;

  /// The parsed command result, if resolution succeeded.
  final ParsedCommandResult? parsedCommand;

  const DartedExecutionResult({
    required this.exitCode,
    this.message,
    this.error,
    this.stackTrace,
    this.parsedCommand,
  });

  /// Factory for a successful execution.
  factory DartedExecutionResult.success({
    String? message,
    ParsedCommandResult? parsedCommand,
  }) =>
      DartedExecutionResult(
        exitCode: 0,
        message: message,
        parsedCommand: parsedCommand,
      );

  /// Factory for a failed execution.
  factory DartedExecutionResult.failure({
    int exitCode = 1,
    String? message,
    Object? error,
    StackTrace? stackTrace,
    ParsedCommandResult? parsedCommand,
  }) =>
      DartedExecutionResult(
        exitCode: exitCode,
        message: message,
        error: error,
        stackTrace: stackTrace,
        parsedCommand: parsedCommand,
      );

  @override
  String toString() =>
      'DartedExecutionResult(exitCode: $exitCode, isSuccess: $isSuccess, message: $message, error: $error)';
}
