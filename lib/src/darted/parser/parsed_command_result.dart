import '../models/darted_command.model.dart';
import '../models/darted_flag.model.dart';

/// The result of parsing and resolving command-line input against a command tree.
class ParsedCommandResult {
  /// The leaf command resolved by the parser.
  final DartedCommand command;

  /// The full hierarchy path of commands traversed (root down to [command]).
  final List<DartedCommand> commandPath;

  /// Parsed options with values, normalized to the option's primary [name].
  final Map<String, dynamic> arguments;

  /// Parsed boolean flags, normalized to the flag's primary [name].
  final Map<String, bool> flags;

  /// Positional arguments passed to the command in order.
  final List<String> positionalArguments;

  /// Any arguments passed after the `--` end-of-options delimiter.
  final List<String> rest;

  const ParsedCommandResult({
    required this.command,
    required this.commandPath,
    required this.arguments,
    required this.flags,
    required this.positionalArguments,
    this.rest = const [],
  });

  /// Whether the standard or customized help flag was passed.
  bool get isHelpRequested =>
      flags[DartedFlag.help.name] == true ||
      flags[DartedFlag.help.abbreviation] == true;

  /// Whether the standard or customized version flag was passed.
  bool get isVersionRequested =>
      flags[DartedFlag.version.name] == true ||
      flags[DartedFlag.version.abbreviation] == true;

  @override
  String toString() =>
      'ParsedCommandResult(command: ${command.name}, path: ${commandPath.map((c) => c.name).join(" -> ")}, arguments: $arguments, flags: $flags, positionals: $positionalArguments, rest: $rest)';
}
