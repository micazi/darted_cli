import 'package:darted_cli/darted_cli.dart';
import 'package:test/test.dart';

void main() {
  group('Core Regression Tests', () {
    late List<DartedCommand> fullTree;
    Map<String, dynamic>? lastArgs;
    Map<String, bool>? lastFlags;

    setUp(() {
      lastArgs = null;
      lastFlags = null;

      fullTree = [
        DartedCommand(
          name: 'project',
          helperDescription: 'Manage project resources',
          callback: (args, flags) {
            lastArgs = args;
            lastFlags = flags;
          },
          arguments: [
            DartedArgument(
              name: 'config',
              abbreviation: 'c',
              defaultValue: 'default.yaml',
            ),
          ],
          flags: [
            DartedFlag(
              name: 'verbose',
              abbreviation: 'v',
              canBeNegated: true,
            ),
            DartedFlag(
              name: 'all',
              abbreviation: 'a',
              canBeNegated: false,
            ),
            DartedFlag(
              name: 'watch',
              abbreviation: 'w',
              appliedByDefault: true,
            ),
          ],
          subCommands: [
            DartedCommand(
              name: 'create',
              helperDescription: 'Create a resource',
              callback: (args, flags) {
                lastArgs = args;
                lastFlags = flags;
              },
              arguments: [
                DartedArgument(
                  name: 'name',
                  abbreviation: 'n',
                  isMainReq: true,
                ),
                DartedArgument(
                  name: 'output-dir',
                  abbreviation: 'o',
                  defaultValue: 'build/',
                ),
                DartedArgument(
                  name: 'destination',
                  abbreviation: 'd',
                  isMainReq: true,
                ),
                DartedArgument(
                  name: 'env',
                  abbreviation: 'e',
                  isMultiOption: true,
                  acceptedMultiOptionValues: 'dev,stage,prod',
                ),
              ],
              flags: [
                DartedFlag(
                  name: 'force',
                  abbreviation: 'f',
                  canBeNegated: true,
                ),
              ],
              subCommands: [
                DartedCommand(
                  name: 'module',
                  helperDescription: 'Create a nested module',
                  callback: (args, flags) {
                    lastArgs = args;
                    lastFlags = flags;
                  },
                ),
              ],
            ),
            DartedCommand(
              name: 'delete',
              callback: (args, flags) {
                lastArgs = args;
                lastFlags = flags;
              },
              subCommands: [
                // Duplicate command name 'create' under a different branch
                DartedCommand(
                  name: 'create',
                  callback: (args, flags) {
                    lastArgs = args;
                    lastFlags = flags;
                  },
                ),
              ],
            ),
          ],
        ),
      ];
    });

    test('1. Resolves deeply nested command hierarchies (3+ levels)', () async {
      final res = await dartedExecute(
        commandsTree: fullTree,
        input: ['project', 'create', 'module'],
      );

      expect(res.isSuccess, isTrue);
      expect(res.parsedCommand!.command.name, equals('module'));
      expect(
        res.parsedCommand!.commandPath.map((c) => c.name),
        equals(['project', 'create', 'module']),
      );
    });

    test(
        '2. Resolves duplicate command names across different branches without collision',
        () async {
      final res1 = await dartedExecute(
        commandsTree: fullTree,
        input: ['project', 'create', 'app1', 'dest1'],
      );
      expect(res1.parsedCommand!.commandPath.map((c) => c.name),
          equals(['project', 'create']));

      final res2 = await dartedExecute(
        commandsTree: fullTree,
        input: ['project', 'delete', 'create'],
      );
      expect(res2.parsedCommand!.commandPath.map((c) => c.name),
          equals(['project', 'delete', 'create']));
    });

    test('3. Handles command names matching argument values', () async {
      final res = await dartedExecute(
        commandsTree: fullTree,
        input: [
          'project',
          'create',
          'project',
          'dest_dir',
          '--output-dir',
          'create'
        ],
      );

      expect(res.isSuccess, isTrue);
      expect(lastArgs?['name'], equals('project'));
      expect(lastArgs?['destination'], equals('dest_dir'));
      expect(lastArgs?['output-dir'], equals('create'));
    });

    test('4. Handles multiple positional arguments in order', () async {
      final res = await dartedExecute(
        commandsTree: fullTree,
        input: ['project', 'create', 'first_pos', 'second_pos'],
      );

      expect(res.isSuccess, isTrue);
      expect(lastArgs?['name'], equals('first_pos'));
      expect(lastArgs?['destination'], equals('second_pos'));
    });

    test('5. Handles options with separate and attached values', () async {
      final res1 = await dartedExecute(
        commandsTree: fullTree,
        input: ['project', 'create', 'app', 'dest', '--output-dir=custom/path'],
      );
      expect(res1.isSuccess, isTrue);
      expect(lastArgs?['output-dir'], equals('custom/path'));

      final res2 = await dartedExecute(
        commandsTree: fullTree,
        input: ['project', 'create', 'app', 'dest', '-ocustom/path2'],
      );
      expect(res2.isSuccess, isTrue);
      expect(lastArgs?['output-dir'], equals('custom/path2'));
    });

    test('6. Handles combined short flags and flag negation', () async {
      final res = await dartedExecute(
        commandsTree: fullTree,
        input: ['project', '-va', '--no-verbose'],
      );

      expect(res.isSuccess, isTrue);
      expect(lastFlags?['all'], isTrue);
      expect(lastFlags?['verbose'], isFalse); // Negation overrode previous true
      expect(lastFlags?['watch'], isTrue); // Applied by default
    });

    test('7. Handles the -- end-of-options delimiter', () async {
      final res = await dartedExecute(
        commandsTree: fullTree,
        input: [
          'project',
          'create',
          'app',
          'dest',
          '--',
          '--not-an-option',
          '-z'
        ],
      );

      expect(res.isSuccess, isTrue);
      expect(lastArgs?['name'], equals('app'));
      expect(lastArgs?['destination'], equals('dest'));
      expect(res.parsedCommand!.rest, equals(['--not-an-option', '-z']));
    });

    test('8. Validates required arguments and accepted values', () async {
      // Missing required argument
      final resMissing = await dartedExecute(
        commandsTree: fullTree,
        input: ['project', 'create'],
      );
      expect(resMissing.isSuccess, isFalse);
      expect(resMissing.exitCode, equals(1));
      expect(resMissing.error, isA<MissingRequiredArgumentException>());

      // Invalid option choice
      final resInvalid = await dartedExecute(
        commandsTree: fullTree,
        input: ['project', 'create', 'app', 'dest', '-e', 'invalid_env'],
      );
      expect(resInvalid.isSuccess, isFalse);
      expect(resInvalid.exitCode, equals(1));
      expect(resInvalid.error, isA<InvalidOptionValueException>());
    });

    test('9. Bypasses required arguments on help and version requests',
        () async {
      final resHelp = await dartedExecute(
        commandsTree: fullTree,
        input: ['project', 'create', '-h'],
      );
      expect(resHelp.isSuccess, isTrue);
      expect(resHelp.exitCode, equals(0));
      expect(resHelp.message, contains('create'));

      final resVer = await dartedExecute(
        commandsTree: fullTree,
        input: ['-v'],
      );
      expect(resVer.isSuccess, isTrue);
      expect(resVer.message, contains('Current installed version:'));
    });
  });
}
