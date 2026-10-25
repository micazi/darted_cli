import 'package:darted_cli/src/darted/parser/cli_token.dart';
import 'package:darted_cli/src/darted/parser/cli_tokenizer.dart';
import 'package:test/test.dart';

void main() {
  const tokenizer = CliTokenizer();

  group('CliTokenizer', () {
    test('tokenizes words and subcommands', () {
      final tokens = tokenizer.tokenize(['create', 'my_app', 'lib/src']);
      expect(tokens, hasLength(3));
      expect(tokens[0],
          isA<WordToken>().having((t) => t.value, 'value', 'create'));
      expect(tokens[1],
          isA<WordToken>().having((t) => t.value, 'value', 'my_app'));
      expect(tokens[2],
          isA<WordToken>().having((t) => t.value, 'value', 'lib/src'));
    });

    test('preserves kebab-case on long options', () {
      final tokens =
          tokenizer.tokenize(['--output-dir', 'build/web', '--no-cache']);
      expect(tokens, hasLength(3));
      expect(
        tokens[0],
        isA<LongOptionToken>()
            .having((t) => t.name, 'name', 'output-dir')
            .having((t) => t.inlineValue, 'inlineValue', isNull),
      );
      expect(tokens[1],
          isA<WordToken>().having((t) => t.value, 'value', 'build/web'));
      expect(
        tokens[2],
        isA<LongOptionToken>()
            .having((t) => t.name, 'name', 'no-cache')
            .having((t) => t.inlineValue, 'inlineValue', isNull),
      );
    });

    test('tokenizes long options with inline = value', () {
      final tokens = tokenizer.tokenize(['--name=my_project', '--env=prod=1']);
      expect(tokens, hasLength(2));
      expect(
        tokens[0],
        isA<LongOptionToken>()
            .having((t) => t.name, 'name', 'name')
            .having((t) => t.inlineValue, 'inlineValue', 'my_project'),
      );
      // Handles values containing '='
      expect(
        tokens[1],
        isA<LongOptionToken>()
            .having((t) => t.name, 'name', 'env')
            .having((t) => t.inlineValue, 'inlineValue', 'prod=1'),
      );
    });

    test('tokenizes short option tokens', () {
      final tokens = tokenizer.tokenize(['-v', '-rf', '-n=val', '-p8080']);
      expect(tokens, hasLength(4));
      expect(tokens[0],
          isA<ShortOptionToken>().having((t) => t.rawContent, 'raw', 'v'));
      expect(tokens[1],
          isA<ShortOptionToken>().having((t) => t.rawContent, 'raw', 'rf'));
      expect(tokens[2],
          isA<ShortOptionToken>().having((t) => t.rawContent, 'raw', 'n=val'));
      expect(tokens[3],
          isA<ShortOptionToken>().having((t) => t.rawContent, 'raw', 'p8080'));
    });

    test('treats tokens after -- as words even if prefixed with - or --', () {
      final tokens =
          tokenizer.tokenize(['run', '--', '--verbose', '-f', 'file.dart']);
      expect(tokens, hasLength(5));
      expect(
          tokens[0], isA<WordToken>().having((t) => t.value, 'value', 'run'));
      expect(tokens[1], isA<EndOfOptionsToken>());
      expect(tokens[2],
          isA<WordToken>().having((t) => t.value, 'value', '--verbose'));
      expect(tokens[3], isA<WordToken>().having((t) => t.value, 'value', '-f'));
      expect(tokens[4],
          isA<WordToken>().having((t) => t.value, 'value', 'file.dart'));
    });

    test('treats single - as WordToken', () {
      final tokens = tokenizer.tokenize(['cat', '-']);
      expect(tokens, hasLength(2));
      expect(tokens[1], isA<WordToken>().having((t) => t.value, 'value', '-'));
    });
  });
}
