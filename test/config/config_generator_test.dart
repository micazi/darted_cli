import 'dart:io';

import 'package:darted_cli/darted_cli.dart';
import 'package:test/test.dart';

import '../test_helpers.dart';

void main() {
  group('ConfigGenerator', () {
    test('generates sample YAML for simple command with arguments and flags',
        () {
      final tree = [
        DartedCommand(
          name: 'serve',
          helperDescription: 'Start the development server.',
          arguments: [
            DartedArgument(
              name: 'port',
              abbreviation: 'p',
              defaultValue: '8080',
              description: 'Port to bind to.',
            ),
            DartedArgument(
              name: 'env',
              abbreviation: 'e',
              defaultValue: 'dev',
              acceptedMultiOptionValues: 'dev,staging,prod',
              description: 'Target environment.',
            ),
          ],
          flags: [
            DartedFlag(
              name: 'verbose',
              abbreviation: 'v',
              description: 'Enable verbose logging.',
              appliedByDefault: false,
            ),
          ],
          callback: (args, flags) {},
        ),
      ];

      final generator = ConfigGenerator(tree);
      final yaml = generator.generate(toolName: 'my_tool');

      expect(yaml, contains('# Sample Configuration File for my_tool'));
      expect(yaml, contains('# Start the development server.'));
      expect(yaml, contains('serve:'));
      expect(yaml, contains('  # Port to bind to.'));
      expect(yaml, contains('  # Default: 8080'));
      expect(yaml, contains('  port: 8080'));
      expect(yaml, contains('  # Target environment.'));
      expect(yaml, contains('  # Accepted values: [dev, staging, prod]'));
      expect(yaml, contains('  env: dev'));
      expect(yaml, contains('  # Enable verbose logging.'));
      expect(yaml, contains('  # Default: false'));
      expect(yaml, contains('  verbose: false'));
    });

    test('excludes non-configurable commands, arguments, and flags', () {
      final tree = [
        DartedCommand(
          name: 'internal',
          isConfigurableInFile: false,
          callback: (args, flags) {},
        ),
        DartedCommand(
          name: 'deploy',
          arguments: [
            DartedArgument(
              name: 'target',
              abbreviation: 't',
              defaultValue: 'prod',
              isConfigurableInFile: true,
            ),
            DartedArgument(
              name: 'secret-token',
              abbreviation: 's',
              isConfigurableInFile: false,
            ),
          ],
          flags: [
            DartedFlag(
              name: 'dry-run',
              abbreviation: 'd',
              isConfigurableInFile: true,
            ),
            DartedFlag(
              name: 'bypass-auth',
              abbreviation: 'b',
              isConfigurableInFile: false,
            ),
          ],
          callback: (args, flags) {},
        ),
      ];

      final generator = ConfigGenerator(tree);
      final yaml = generator.generate();

      expect(yaml, isNot(contains('internal:')));
      expect(yaml, contains('deploy:'));
      expect(yaml, contains('  target: prod'));
      expect(yaml, isNot(contains('secret-token:')));
      expect(yaml, contains('  dry-run: false'));
      expect(yaml, isNot(contains('bypass-auth:')));
    });

    test('supports multi-option arguments with and without defaults', () {
      final tree = [
        DartedCommand(
          name: 'build',
          arguments: [
            DartedArgument(
              name: 'targets',
              abbreviation: 't',
              isMultiOption: true,
              defaultValue: 'web,macos',
            ),
            DartedArgument(
              name: 'excludes',
              abbreviation: 'e',
              isMultiOption: true,
            ),
          ],
          callback: (args, flags) {},
        ),
      ];

      final generator = ConfigGenerator(tree);
      final yaml = generator.generate();

      expect(yaml, contains('build:'));
      expect(yaml, contains('  targets:'));
      expect(yaml, contains('    - web'));
      expect(yaml, contains('    - macos'));
      expect(yaml, contains('  excludes: []'));
    });

    test('supports nested subcommands', () {
      final tree = [
        DartedCommand(
          name: 'database',
          helperDescription: 'Database management.',
          subCommands: [
            DartedCommand(
              name: 'migrate',
              helperDescription: 'Run migrations.',
              arguments: [
                DartedArgument(
                  name: 'step',
                  abbreviation: 's',
                  defaultValue: '1',
                ),
              ],
              callback: (args, flags) {},
            ),
          ],
          callback: (args, flags) {},
        ),
      ];

      final generator = ConfigGenerator(tree);
      final yaml = generator.generate();

      expect(yaml, contains('database:'));
      expect(yaml, contains('  # Run migrations.'));
      expect(yaml, contains('  migrate:'));
      expect(yaml, contains('    step: 1'));
    });
  });

  group('generate-sample-config Command E2E', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('darted_sample_config_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('is not registered when generateSampleConfig is false', () async {
      final tree = [
        DartedCommand(
          name: 'test',
          callback: (args, flags) {},
        ),
      ];

      final res = await dartedExecute(
        commandsTree: tree,
        input: ['generate-sample-config'],
        generateSampleConfig: false,
      );

      expect(res.isSuccess, isFalse);
      expect(res.error, isA<UnknownCommandException>());
    });

    test(
        'is registered and writes sample config file when generateSampleConfig is true',
        () async {
      final tree = [
        DartedCommand(
          name: 'serve',
          arguments: [
            DartedArgument(
              name: 'port',
              abbreviation: 'p',
              defaultValue: '3000',
            ),
          ],
          callback: (args, flags) {},
        ),
      ];

      final outPath = '${tempDir.path}/custom_config.yaml';

      final res = await runSilently(
        () => dartedExecute(
          commandsTree: tree,
          input: ['generate-sample-config', '--output', outPath],
          generateSampleConfig: true,
        ),
      );

      expect(res.isSuccess, isTrue);
      final file = File(outPath);
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content, contains('serve:'));
      expect(content, contains('  port: 3000'));
    });

    test('fails if output file exists and --force is not passed', () async {
      final outPath = '${tempDir.path}/existing.yaml';
      File(outPath).writeAsStringSync('existing: content');

      final tree = [
        DartedCommand(
          name: 'serve',
          callback: (args, flags) {},
        ),
      ];

      final res = await dartedExecute(
        commandsTree: tree,
        input: ['generate-sample-config', '--output', outPath],
        generateSampleConfig: true,
      );

      expect(res.isSuccess, isFalse);
      expect(res.error, isA<ConfigException>());
      expect(res.message,
          contains('already exists. Use --force or -f to overwrite.'));
      // Content should NOT be overwritten
      expect(File(outPath).readAsStringSync(), equals('existing: content'));
    });

    test('overwrites existing file when --force is passed', () async {
      final outPath = '${tempDir.path}/existing.yaml';
      File(outPath).writeAsStringSync('existing: content');

      final tree = [
        DartedCommand(
          name: 'serve',
          arguments: [
            DartedArgument(
              name: 'port',
              abbreviation: 'p',
              defaultValue: '9999',
            ),
          ],
          callback: (args, flags) {},
        ),
      ];

      final res = await runSilently(
        () => dartedExecute(
          commandsTree: tree,
          input: ['generate-sample-config', '--output', outPath, '--force'],
          generateSampleConfig: true,
        ),
      );

      expect(res.isSuccess, isTrue);
      final updatedContent = File(outPath).readAsStringSync();
      expect(updatedContent, contains('port: 9999'));
    });
  });
}
