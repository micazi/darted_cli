import 'package:darted_cli/darted_cli.dart';
import 'package:test/test.dart';

void main() {
  final testCommand = DartedCommand(
    name: 'serve',
    arguments: [
      DartedArgument(
        name: 'port',
        abbreviation: 'p',
        defaultValue: '8080',
        environmentVariable: 'APP_PORT',
      ),
      DartedArgument(
        name: 'host',
        abbreviation: 'h',
        defaultValue: 'localhost',
        environmentVariable: 'APP_HOST',
      ),
      DartedArgument(
        name: 'token',
        abbreviation: 't',
        isMainReq: true,
        environmentVariable: 'APP_TOKEN',
      ),
    ],
    flags: [
      DartedFlag(
        name: 'debug',
        abbreviation: 'd',
        appliedByDefault: false,
        environmentVariable: 'APP_DEBUG',
      ),
      DartedFlag(
        name: 'cache',
        abbreviation: 'c',
        appliedByDefault: true,
        environmentVariable: 'APP_CACHE',
      ),
    ],
    callback: (args, flags) {},
  );

  final commandsTree = [testCommand];

  group('Precedence Hierarchy (CLI > Env > Config > Defaults)', () {
    test('CLI arguments and flags override Env, Config, and Defaults',
        () async {
      final res = await dartedExecute(
        commandsTree: commandsTree,
        input: ['serve', '--port', '9999', '--debug', '--token', 'cli-token'],
        environment: {
          'APP_PORT': '7777',
          'APP_DEBUG': 'false',
          'APP_TOKEN': 'env-token',
        },
        configData: {
          'serve': {
            'port': '5555',
            'debug': false,
            'token': 'config-token',
          },
        },
      );

      expect(res.isSuccess, isTrue);
      expect(res.parsedCommand!.arguments['port'], equals('9999'));
      expect(res.parsedCommand!.arguments['token'], equals('cli-token'));
      expect(res.parsedCommand!.flags['debug'], isTrue);
    });

    test(
        'Environment variables override Config and Defaults when omitted from CLI',
        () async {
      final res = await dartedExecute(
        commandsTree: commandsTree,
        input: ['serve'],
        environment: {
          'APP_PORT': '7777',
          'APP_DEBUG': 'true',
          'APP_TOKEN': 'env-token',
        },
        configData: {
          'serve': {
            'port': '5555',
            'debug': false,
            'token': 'config-token',
          },
        },
      );

      expect(res.isSuccess, isTrue);
      expect(res.parsedCommand!.arguments['port'], equals('7777'));
      expect(res.parsedCommand!.arguments['token'], equals('env-token'));
      expect(res.parsedCommand!.flags['debug'], isTrue);
    });

    test('Configuration values override Defaults when omitted from CLI and Env',
        () async {
      final res = await dartedExecute(
        commandsTree: commandsTree,
        input: ['serve'],
        environment: {},
        configData: {
          'serve': {
            'port': '5555',
            'debug': true,
            'token': 'config-token',
          },
        },
      );

      expect(res.isSuccess, isTrue);
      expect(res.parsedCommand!.arguments['port'], equals('5555'));
      expect(res.parsedCommand!.arguments['token'], equals('config-token'));
      expect(res.parsedCommand!.flags['debug'], isTrue);
    });

    test('Declared Defaults are used when omitted from CLI, Env, and Config',
        () async {
      final res = await dartedExecute(
        commandsTree: commandsTree,
        input: ['serve', '--token', 'req-token'],
        environment: {},
        configData: {},
      );

      expect(res.isSuccess, isTrue);
      expect(res.parsedCommand!.arguments['port'], equals('8080'));
      expect(res.parsedCommand!.arguments['host'], equals('localhost'));
      expect(res.parsedCommand!.flags['debug'] ?? false, isFalse);
      expect(
          res.parsedCommand!.flags['cache'], isTrue); // appliedByDefault: true
    });

    test('Omitted CLI value does not erase lower-priority valid value',
        () async {
      // CLI sets --port, but leaves --host to Env, and --token to Config
      final res = await dartedExecute(
        commandsTree: commandsTree,
        input: ['serve', '--port', '4000'],
        environment: {'APP_HOST': '0.0.0.0'},
        configData: {
          'serve': {'token': 'cfg-tok'},
        },
      );

      expect(res.isSuccess, isTrue);
      expect(res.parsedCommand!.arguments['port'], equals('4000'));
      expect(res.parsedCommand!.arguments['host'], equals('0.0.0.0'));
      expect(res.parsedCommand!.arguments['token'], equals('cfg-tok'));
    });

    test(
        'Required argument can be fulfilled by Env or Config without CLI argument',
        () async {
      final res = await dartedExecute(
        commandsTree: commandsTree,
        input: ['serve'],
        environment: {'APP_TOKEN': 'fulfilled-via-env'},
      );

      expect(res.isSuccess, isTrue);
      expect(
          res.parsedCommand!.arguments['token'], equals('fulfilled-via-env'));
    });

    test(
        'Required argument throws MissingRequiredArgumentException if missing from all sources',
        () async {
      final res = await dartedExecute(
        commandsTree: commandsTree,
        input: ['serve'],
        environment: {},
        configData: {},
      );

      expect(res.isSuccess, isFalse);
      expect(res.error, isA<MissingRequiredArgumentException>());
    });

    test(
        'Invalid higher-priority value throws error and does NOT silently fall back',
        () async {
      final restrictedTree = [
        DartedCommand(
          name: 'deploy',
          arguments: [
            DartedArgument(
              name: 'env',
              abbreviation: 'e',
              defaultValue: 'dev',
              acceptedMultiOptionValues: 'dev,staging,prod',
              environmentVariable: 'DEPLOY_ENV',
            ),
          ],
          callback: (args, flags) {},
        ),
      ];

      // Env has invalid value "qa" - must fail, NOT fall back to default "dev"
      final res = await dartedExecute(
        commandsTree: restrictedTree,
        input: ['deploy'],
        environment: {'DEPLOY_ENV': 'qa'},
      );

      expect(res.isSuccess, isFalse);
      expect(res.error, isA<InvalidOptionValueException>());
    });
  });
}
