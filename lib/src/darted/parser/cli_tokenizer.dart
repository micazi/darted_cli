import 'cli_token.dart';

/// Tokenizes a raw list of command line arguments into structured [CliToken]s.
class CliTokenizer {
  const CliTokenizer();

  /// Tokenizes [arguments] into a list of [CliToken].
  List<CliToken> tokenize(List<String> arguments) {
    final tokens = <CliToken>[];
    var endOfOptionsReached = false;

    for (final arg in arguments) {
      if (endOfOptionsReached) {
        tokens.add(WordToken(arg, value: arg));
        continue;
      }

      if (arg == '--') {
        endOfOptionsReached = true;
        tokens.add(EndOfOptionsToken(arg));
      } else if (arg.startsWith('--')) {
        final equalsIndex = arg.indexOf('=');
        if (equalsIndex != -1) {
          final name = arg.substring(2, equalsIndex);
          final value = arg.substring(equalsIndex + 1);
          tokens.add(LongOptionToken(arg, name: name, inlineValue: value));
        } else {
          final name = arg.substring(2);
          tokens.add(LongOptionToken(arg, name: name));
        }
      } else if (arg.startsWith('-') && arg.length > 1) {
        tokens.add(ShortOptionToken(arg, rawContent: arg.substring(1)));
      } else {
        // Plain word or single '-' (often used for stdin)
        tokens.add(WordToken(arg, value: arg));
      }
    }

    return tokens;
  }
}
