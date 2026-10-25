import 'package:darted_cli/darted_cli.dart';
import 'package:test/test.dart';

void main() {
  group('Argument Validation & Conversion', () {
    late List<DartedCommand> tree;

    setUp(() {
      tree = [
        DartedCommand(
          name: 'deploy',
          callback: (_, __) {},
          arguments: [
            DartedArgument(
              name: 'environment',
              abbreviation: 'e',
              isMultiOption: true,
              acceptedMultiOptionValues: 'dev,staging,prod',
            ),
            DartedArgument(
              name: 'service',
              abbreviation: 's',
              isMainReq: true,
            ),
          ],
        ),
      ];
    });

    test(
        'throws MissingRequiredArgumentException when required positional is omitted',
        () {
      final resolver = CommandResolver(tree);
      expect(
        () => resolver.resolve(['deploy']),
        throwsA(
          isA<MissingRequiredArgumentException>()
              .having((e) => e.argumentName, 'argumentName', 'service')
              .having((e) => e.isPositional, 'isPositional', isTrue),
        ),
      );
    });

    test('validates accepted multi-option values when valid', () {
      final resolver = CommandResolver(tree);
      final res =
          resolver.resolve(['deploy', 'auth-service', '-e', 'staging,prod']);

      expect(res!.arguments['service'], equals('auth-service'));
      expect(res.arguments['environment'], equals('staging,prod'));
    });

    test(
        'throws InvalidOptionValueException when option value is not in accepted values',
        () {
      final resolver = CommandResolver(tree);
      expect(
        () => resolver
            .resolve(['deploy', 'auth-service', '-e', 'dev,unknown_env']),
        throwsA(
          isA<InvalidOptionValueException>()
              .having((e) => e.option, 'option', 'environment')
              .having((e) => e.value, 'value', 'unknown_env')
              .having((e) => e.acceptedValues, 'acceptedValues',
                  ['dev', 'staging', 'prod']),
        ),
      );
    });

    test('bypasses required argument validation when help flag is passed', () {
      final resolver = CommandResolver(tree);
      final res = resolver.resolve(['deploy', '--help']);

      expect(res, isNotNull);
      expect(res!.isHelpRequested, isTrue);
      // Missing positional 'service' does NOT throw
    });

    test('bypasses required argument validation when version flag is passed',
        () {
      final resolver = CommandResolver(tree);
      final res = resolver.resolve(['deploy', '--version']);

      expect(res, isNotNull);
      expect(res!.isVersionRequested, isTrue);
      // Missing positional 'service' does NOT throw
    });
  });
}
