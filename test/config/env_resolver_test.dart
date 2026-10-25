import 'package:darted_cli/darted_cli.dart';
import 'package:test/test.dart';

void main() {
  final testCmd = DartedCommand(
    name: 'serve',
    arguments: [
      DartedArgument(
        name: 'port',
        abbreviation: 'p',
        environmentVariable: 'APP_PORT',
      ),
      DartedArgument(
        name: 'mode',
        abbreviation: 'm',
        environmentVariable: 'APP_MODE',
        acceptedMultiOptionValues: 'dev,staging,prod',
      ),
      DartedArgument(
        name: 'tags',
        abbreviation: 't',
        isMultiOption: true,
        environmentVariable: 'APP_TAGS',
        acceptedMultiOptionValues: 'api,web,worker',
      ),
    ],
    flags: [
      DartedFlag(
        name: 'debug',
        abbreviation: 'd',
        environmentVariable: 'APP_DEBUG',
      ),
      DartedFlag(
        name: 'strict',
        abbreviation: 's',
        appliedByDefault: true,
        canBeNegated: false,
        environmentVariable: 'APP_STRICT',
      ),
    ],
    callback: (args, flags) {},
  );

  group('EnvResolver Argument Resolution', () {
    test('resolves scalar arguments from environment map', () {
      final env = {'APP_PORT': '9090', 'APP_MODE': 'prod'};
      final resolver = EnvResolver(env);

      final resolved = resolver.resolveArguments(testCmd);
      expect(resolved['port'], equals('9090'));
      expect(resolved['mode'], equals('prod'));
    });

    test('ignores unset or empty environment variables', () {
      final env = {'APP_PORT': '   ', 'OTHER_VAR': 'value'};
      final resolver = EnvResolver(env);

      final resolved = resolver.resolveArguments(testCmd);
      expect(resolved.containsKey('port'), isFalse);
    });

    test('resolves and splits multi-option arguments', () {
      final env = {'APP_TAGS': 'api, worker'};
      final resolver = EnvResolver(env);

      final resolved = resolver.resolveArguments(testCmd);
      expect(resolved['tags'], equals(['api', 'worker']));
    });

    test('validates accepted values for single-option argument', () {
      final env = {'APP_MODE': 'unsupported'};
      final resolver = EnvResolver(env);

      expect(
        () => resolver.resolveArguments(testCmd),
        throwsA(isA<InvalidOptionValueException>()),
      );
    });

    test('validates accepted values for multi-option argument', () {
      final env = {'APP_TAGS': 'api, invalid_tag'};
      final resolver = EnvResolver(env);

      expect(
        () => resolver.resolveArguments(testCmd),
        throwsA(isA<InvalidOptionValueException>()),
      );
    });
  });

  group('EnvResolver Flag Resolution', () {
    test('resolves truthy flag values', () {
      for (final val in ['true', '1', 'yes', 'on', 'TRUE']) {
        final resolver = EnvResolver({'APP_DEBUG': val});
        final flags = resolver.resolveFlags(testCmd);
        expect(flags['debug'], isTrue,
            reason: 'Expected $val to resolve to true');
      }
    });

    test('resolves falsy flag values', () {
      for (final val in ['false', '0', 'no', 'off', 'FALSE']) {
        final resolver = EnvResolver({'APP_DEBUG': val});
        final flags = resolver.resolveFlags(testCmd);
        expect(flags['debug'], isFalse,
            reason: 'Expected $val to resolve to false');
      }
    });

    test('throws on unrecognized boolean values', () {
      final resolver = EnvResolver({'APP_DEBUG': 'maybe'});
      expect(
        () => resolver.resolveFlags(testCmd),
        throwsA(isA<ConfigException>()),
      );
    });

    test('throws when attempting to negate flag with canBeNegated: false', () {
      final resolver = EnvResolver({'APP_STRICT': 'false'});
      expect(
        () => resolver.resolveFlags(testCmd),
        throwsA(isA<FlagCannotBeNegatedException>()),
      );
    });
  });
}
