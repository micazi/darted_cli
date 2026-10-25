import 'package:darted_cli/darted_cli.dart';
import 'package:test/test.dart';

void main() {
  group('DartedCommand Configuration Eligibility & copyWith', () {
    test('defaults isConfigurableInFile to true', () {
      final cmd = DartedCommand(
        name: 'test',
        callback: (args, flags) {},
      );
      expect(cmd.isConfigurableInFile, isTrue);
    });

    test('can set isConfigurableInFile to false', () {
      final cmd = DartedCommand(
        name: 'secret',
        callback: (args, flags) {},
        isConfigurableInFile: false,
      );
      expect(cmd.isConfigurableInFile, isFalse);
    });

    test('copyWith properly updates isConfigurableInFile and preserves fields',
        () {
      final cmd = DartedCommand(
        name: 'serve',
        callback: (args, flags) {},
        helperDescription: 'Serve app',
        isConfigurableInFile: true,
      );

      final copy = cmd.copyWith(isConfigurableInFile: false);
      expect(copy.name, equals('serve'));
      expect(copy.helperDescription, equals('Serve app'));
      expect(copy.isConfigurableInFile, isFalse);
    });
  });

  group('DartedArgument Configuration Eligibility, Env Var & copyWith', () {
    test(
        'defaults isConfigurableInFile to true and environmentVariable to null',
        () {
      final arg = DartedArgument(
        name: 'port',
        abbreviation: 'p',
      );
      expect(arg.isConfigurableInFile, isTrue);
      expect(arg.environmentVariable, isNull);
    });

    test('accepts custom isConfigurableInFile and environmentVariable', () {
      final arg = DartedArgument(
        name: 'token',
        abbreviation: 't',
        isConfigurableInFile: false,
        environmentVariable: 'APP_SECRET_TOKEN',
      );
      expect(arg.isConfigurableInFile, isFalse);
      expect(arg.environmentVariable, equals('APP_SECRET_TOKEN'));
    });

    test('copyWith updates fields appropriately', () {
      final arg = DartedArgument(
        name: 'port',
        abbreviation: 'p',
        defaultValue: '8080',
      );

      final updated = arg.copyWith(
        isConfigurableInFile: false,
        environmentVariable: 'PORT',
      );
      expect(updated.name, equals('port'));
      expect(updated.defaultValue, equals('8080'));
      expect(updated.isConfigurableInFile, isFalse);
      expect(updated.environmentVariable, equals('PORT'));
    });
  });

  group('DartedFlag Configuration Eligibility, Env Var & copyWith', () {
    test(
        'defaults isConfigurableInFile to true and environmentVariable to null',
        () {
      final flag = DartedFlag(
        name: 'verbose',
        abbreviation: 'v',
      );
      expect(flag.isConfigurableInFile, isTrue);
      expect(flag.environmentVariable, isNull);
    });

    test(
        'built-in help and version flags have isConfigurableInFile set to false',
        () {
      expect(DartedFlag.help.isConfigurableInFile, isFalse);
      expect(DartedFlag.version.isConfigurableInFile, isFalse);
    });

    test('accepts custom isConfigurableInFile and environmentVariable', () {
      final flag = DartedFlag(
        name: 'debug',
        abbreviation: 'd',
        isConfigurableInFile: false,
        environmentVariable: 'APP_DEBUG',
      );
      expect(flag.isConfigurableInFile, isFalse);
      expect(flag.environmentVariable, equals('APP_DEBUG'));
    });

    test('copyWith updates fields appropriately', () {
      final flag = DartedFlag(
        name: 'debug',
        abbreviation: 'd',
      );

      final updated = flag.copyWith(
        isConfigurableInFile: false,
        environmentVariable: 'DEBUG',
      );
      expect(updated.name, equals('debug'));
      expect(updated.isConfigurableInFile, isFalse);
      expect(updated.environmentVariable, equals('DEBUG'));
    });
  });
}
