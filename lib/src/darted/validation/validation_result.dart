/// Base exception for all errors produced by `darted_cli`.
abstract class DartedException implements Exception {
  final String message;

  const DartedException(this.message);

  @override
  String toString() => message;
}

/// Thrown when input validation fails against defined command, option, or flag rules.
abstract class DartedValidationException extends DartedException {
  const DartedValidationException(super.message);
}

/// Thrown when a specified command or subcommand is not found in the command tree.
class UnknownCommandException extends DartedValidationException {
  final String command;
  final String? closestMatch;

  UnknownCommandException(this.command, {this.closestMatch})
      : super(
          "Command '$command' is not recognized."
          "${closestMatch != null ? " Did you mean '$closestMatch'?" : ""}",
        );
}

/// Thrown when an option or flag is passed that is not defined for the command.
class UnknownOptionException extends DartedValidationException {
  final String option;
  final String command;
  final String? closestMatch;

  UnknownOptionException(
    this.option, {
    required this.command,
    this.closestMatch,
  }) : super(
          "Unknown option '$option' for command '$command'."
          "${closestMatch != null ? " Did you mean '$closestMatch'?" : ""}",
        );
}

/// Thrown when an option that requires a value is not supplied one.
class MissingArgumentValueException extends DartedValidationException {
  final String option;
  final String command;

  MissingArgumentValueException(this.option, {required this.command})
      : super("Option '$option' requires a value for command '$command'.");
}

/// Thrown when a required argument or positional argument is missing.
class MissingRequiredArgumentException extends DartedValidationException {
  final String argumentName;
  final String command;
  final bool isPositional;

  MissingRequiredArgumentException(
    this.argumentName, {
    required this.command,
    this.isPositional = false,
  }) : super(
          isPositional
              ? "Missing required positional argument '$argumentName' for command '$command'."
              : "Missing required argument '--$argumentName' for command '$command'.",
        );
}

/// Thrown when an option value is not one of the allowed options.
class InvalidOptionValueException extends DartedValidationException {
  final String option;
  final dynamic value;
  final String command;
  final List<String> acceptedValues;

  InvalidOptionValueException(
    this.option,
    this.value, {
    required this.command,
    required this.acceptedValues,
  }) : super(
          "Invalid value '$value' for option '$option' in command '$command'. "
          "Accepted values are: ${acceptedValues.join(', ')}.",
        );
}

/// Thrown when a flag is negated (e.g. `--no-flag`) but `canBeNegated` is false.
class FlagCannotBeNegatedException extends DartedValidationException {
  final String flagName;
  final String command;

  FlagCannotBeNegatedException(this.flagName, {required this.command})
      : super("Flag '--$flagName' cannot be negated in command '$command'.");
}

/// Thrown when configuration file generation, loading, or resolution fails.
class ConfigException extends DartedValidationException {
  const ConfigException(super.message);
}
