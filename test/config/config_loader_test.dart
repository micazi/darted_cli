import 'dart:io';

import 'package:darted_cli/darted_cli.dart';
import 'package:test/test.dart';

void main() {
  final testTree = [
    DartedCommand(
      name: 'serve',
      arguments: [
        DartedArgument(
          name: 'port',
          abbreviation: 'p',
          defaultValue: '8080',
        ),
        DartedArgument(
          name: 'env',
          abbreviation: 'e',
          acceptedMultiOptionValues: 'dev,staging,prod',
        ),
        DartedArgument(
          name: 'secret-token',
          abbreviation: 's',
          isConfigurableInFile: false,
        ),
        DartedArgument(
          name: 'tags',
          abbreviation: 't',
          isMultiOption: true,
          acceptedMultiOptionValues: 'alpha,beta,rc',
        ),
      ],
      flags: [
        DartedFlag(
          name: 'debug',
          abbreviation: 'd',
        ),
      ],
      subCommands: [
        DartedCommand(
          name: 'worker',
          arguments: [
            DartedArgument(
              name: 'concurrency',
              abbreviation: 'c',
              defaultValue: '4',
            ),
          ],
          callback: (args, flags) {},
        ),
      ],
      callback: (args, flags) {},
    ),
  ];

  late ConfigLoader loader;

  setUp(() {
    loader = ConfigLoader(testTree);
  });

  group('ConfigLoader Loading & Parsing', () {
    test('loads valid YAML content successfully', () {
      const yaml = '''
serve:
  port: 9000
  env: prod
  debug: true
  tags:
    - alpha
    - beta
  worker:
    concurrency: 8
''';
      final config = loader.loadString(yaml);
      expect(config['serve']['port'], equals(9000));
      expect(config['serve']['env'], equals('prod'));
      expect(config['serve']['debug'], isTrue);
      expect(config['serve']['tags'], equals(['alpha', 'beta']));
      expect(config['serve']['worker']['concurrency'], equals(8));
    });

    test('loads valid JSON content as YAML', () {
      const json = '''
{
  "serve": {
    "port": 7000,
    "env": "staging",
    "debug": false
  }
}
''';
      final config = loader.loadString(json);
      expect(config['serve']['port'], equals(7000));
      expect(config['serve']['env'], equals('staging'));
    });

    test('returns empty map for empty or blank content', () {
      expect(loader.loadString(''), isEmpty);
      expect(loader.loadString('   \n  '), isEmpty);
    });

    test('throws on non-mapping root', () {
      expect(
        () => loader.loadString('- list item\n- another'),
        throwsA(isA<ConfigException>()),
      );
    });

    test('throws on invalid YAML syntax', () {
      expect(
        () => loader.loadString('serve:\n  invalid: [unclosed'),
        throwsA(isA<ConfigException>()),
      );
    });

    test('handles file loading and missing file behavior', () {
      final tempDir = Directory.systemTemp.createTempSync('darted_loader_');
      final testFile = File('${tempDir.path}/app.yaml');
      testFile.writeAsStringSync('serve:\n  port: 5000');

      try {
        final config = loader.loadFile(testFile.path);
        expect(config['serve']['port'], equals(5000));

        // Missing file with mustExist: false
        expect(
            loader.loadFile('${tempDir.path}/non_existent.yaml',
                mustExist: false),
            isEmpty);

        // Missing file with mustExist: true
        expect(
          () => loader.loadFile('${tempDir.path}/non_existent.yaml',
              mustExist: true),
          throwsA(isA<ConfigException>()),
        );
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });

  group('ConfigLoader Validation', () {
    test('rejects unknown root command', () {
      const yaml = '''
unknown_cmd:
  foo: bar
''';
      expect(
        () => loader.loadString(yaml),
        throwsA(
          isA<ConfigException>().having(
            (e) => e.message,
            'message',
            contains('Unknown command or configuration section "unknown_cmd"'),
          ),
        ),
      );
    });

    test('rejects unknown option under command', () {
      const yaml = '''
serve:
  unknown_opt: 123
''';
      expect(
        () => loader.loadString(yaml),
        throwsA(
          isA<ConfigException>().having(
            (e) => e.message,
            'message',
            contains('Unknown option "unknown_opt" under command "serve"'),
          ),
        ),
      );
    });

    test('rejects non-configurable argument', () {
      const yaml = '''
serve:
  secret-token: my-secret
''';
      expect(
        () => loader.loadString(yaml),
        throwsA(
          isA<ConfigException>().having(
            (e) => e.message,
            'message',
            contains(
                'Argument "serve.secret-token" is not configurable in configuration files.'),
          ),
        ),
      );
    });

    test('rejects value not in accepted values', () {
      const yaml = '''
serve:
  env: invalid_env
''';
      expect(
        () => loader.loadString(yaml),
        throwsA(
          isA<ConfigException>().having(
            (e) => e.message,
            'message',
            contains('Invalid value "invalid_env" for argument "serve.env"'),
          ),
        ),
      );
    });

    test('rejects invalid multi-option value not in accepted list', () {
      const yaml = '''
serve:
  tags:
    - alpha
    - invalid_tag
''';
      expect(
        () => loader.loadString(yaml),
        throwsA(
          isA<ConfigException>().having(
            (e) => e.message,
            'message',
            contains('Invalid value "invalid_tag" for argument "serve.tags"'),
          ),
        ),
      );
    });
  });

  group('ConfigLoader extractSectionForPath', () {
    test('extracts nested section for command path', () {
      const yaml = '''
serve:
  port: 8080
  worker:
    concurrency: 16
''';
      final config = loader.loadString(yaml);
      final serveSection = loader.extractSectionForPath(config, ['serve']);
      expect(serveSection['port'], equals(8080));

      final workerSection =
          loader.extractSectionForPath(config, ['serve', 'worker']);
      expect(workerSection['concurrency'], equals(16));

      final nonExistent =
          loader.extractSectionForPath(config, ['serve', 'other']);
      expect(nonExistent, isEmpty);
    });
  });
}
