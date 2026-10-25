/// Represents a lexical token from the command-line arguments.
sealed class CliToken {
  /// The raw string representation as passed in argv.
  final String raw;

  const CliToken(this.raw);

  @override
  String toString() => '$runtimeType($raw)';
}

/// A word token representing either a command name or a positional argument value.
class WordToken extends CliToken {
  final String value;

  const WordToken(super.raw, {required this.value});

  @override
  String toString() => 'WordToken($value)';
}

/// A long option token starting with `--` (e.g. `--output-dir` or `--name=darted`).
class LongOptionToken extends CliToken {
  /// The option name without leading `--` (kebab-case preserved).
  final String name;

  /// The inline value if specified with `=`, otherwise null.
  final String? inlineValue;

  const LongOptionToken(
    super.raw, {
    required this.name,
    this.inlineValue,
  });

  /// Whether this option provided an attached inline value via `=`.
  bool get hasInlineValue => inlineValue != null;

  @override
  String toString() =>
      'LongOptionToken(--$name${inlineValue != null ? '=$inlineValue' : ''})';
}

/// A short option token starting with `-` (e.g. `-v`, `-rf`, `-n=foo`, `-nfoo`).
class ShortOptionToken extends CliToken {
  /// The raw flags or options characters without leading `-`.
  final String rawContent;

  const ShortOptionToken(super.raw, {required this.rawContent});

  @override
  String toString() => 'ShortOptionToken(-$rawContent)';
}

/// The `--` delimiter token, signaling that all subsequent tokens are positional.
class EndOfOptionsToken extends CliToken {
  const EndOfOptionsToken(super.raw);

  @override
  String toString() => 'EndOfOptionsToken(--)';
}
