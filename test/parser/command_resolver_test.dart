import 'package:darted_cli/darted_cli.dart';
import 'package:test/test.dart';

void main() {
  group('CommandResolver - Subcommands and Hierarchies', () {
    late List<DartedCommand> tree;

    setUp(() {
      tree = [
        DartedCommand(
          name: 'git',
          callback: (_, __) {},
          flags: [
            DartedFlag(
              name: 'verbose',
              abbreviation: 'v',
              canBeNegated: true,
            ),
          ],
          subCommands: [
            DartedCommand(
              name: 'remote',
              callback: (_, __) {},
              subCommands: [
                DartedCommand(
                  name: 'add',
                  callback: (_, __) {},
                  arguments: [
                    DartedArgument(
                      name: 'name',
                      abbreviation: 'n',
                      isMainReq: true,
                    ),
                    DartedArgument(
                      name: 'url',
                      abbreviation: 'u',
                      isMainReq: true,
                    ),
                  ],
                ),
                DartedCommand(
                  name: 'remove',
                  callback: (_, __) {},
                ),
              ],
            ),
            DartedCommand(
              name: 'add',
              callback: (_, __) {},
            ),
          ],
        ),
      ];
    });

    test('resolves arbitrarily nested subcommands', () {
      final resolver = CommandResolver(tree);
      final result = resolver.resolve(
          ['git', 'remote', 'add', 'origin', 'https://github.com/repo.git']);

      expect(result, isNotNull);
      expect(result!.command.name, equals('add'));
      expect(result.commandPath.map((c) => c.name),
          equals(['git', 'remote', 'add']));
      expect(result.arguments['name'], equals('origin'));
      expect(result.arguments['url'], equals('https://github.com/repo.git'));
    });

    test(
        'handles duplicate command names across different branches without collision',
        () {
      final resolver = CommandResolver(tree);

      final branch1 =
          resolver.resolve(['git', 'remote', 'add', 'upstream', 'url']);
      expect(branch1!.commandPath.map((c) => c.name),
          equals(['git', 'remote', 'add']));

      final branch2 = resolver.resolve(['git', 'add']);
      expect(branch2!.commandPath.map((c) => c.name), equals(['git', 'add']));
    });

    test(
        'throws UnknownCommandException with closest match on unknown root command',
        () {
      final resolver = CommandResolver(tree);
      expect(
        () => resolver.resolve(['got']),
        throwsA(isA<UnknownCommandException>()
            .having((e) => e.closestMatch, 'closestMatch', 'git')),
      );
    });
  });

  group('CommandResolver - Option and Flag Parsing', () {
    late List<DartedCommand> tree;

    setUp(() {
      tree = [
        DartedCommand(
          name: 'create',
          callback: (_, __) {},
          arguments: [
            DartedArgument(
              name: 'output-dir',
              abbreviation: 'o',
              defaultValue: 'lib/',
            ),
            DartedArgument(
              name: 'platforms',
              abbreviation: 'p',
              isMultiOption: true,
              acceptedMultiOptionValues: 'android,ios,web',
            ),
            DartedArgument(
              name: 'target',
              abbreviation: 't',
              isMainReq: true,
            ),
          ],
          flags: [
            DartedFlag(
              name: 'recursive',
              abbreviation: 'r',
              canBeNegated: true,
            ),
            DartedFlag(
              name: 'force',
              abbreviation: 'f',
              canBeNegated: false,
            ),
            DartedFlag(
              name: 'auto-format',
              abbreviation: 'a',
              appliedByDefault: true,
            ),
          ],
        ),
      ];
    });

    test('supports long options with separate value (--name value)', () {
      final resolver = CommandResolver(tree);
      final res =
          resolver.resolve(['create', '--output-dir', 'src/app', 'my_target']);

      expect(res!.arguments['output-dir'], equals('src/app'));
      expect(res.arguments['target'], equals('my_target'));
    });

    test('supports long options with inline value (--name=value)', () {
      final resolver = CommandResolver(tree);
      final res =
          resolver.resolve(['create', '--output-dir=custom/dir', 'my_target']);

      expect(res!.arguments['output-dir'], equals('custom/dir'));
      expect(res.arguments['target'], equals('my_target'));
    });

    test('preserves kebab-case option names without stripping internal hyphens',
        () {
      final resolver = CommandResolver(tree);
      final res =
          resolver.resolve(['create', '--output-dir', 'build/', 'proj']);

      expect(res!.arguments.containsKey('output-dir'), isTrue);
      expect(res.arguments['output-dir'], equals('build/'));
    });

    test('supports short option with separate value (-n value)', () {
      final resolver = CommandResolver(tree);
      final res = resolver.resolve(['create', '-o', 'build/', 'proj']);

      expect(res!.arguments['output-dir'], equals('build/'));
    });

    test('supports short option with attached value (-nvalue)', () {
      final resolver = CommandResolver(tree);
      final res = resolver.resolve(['create', '-obuild/', 'proj']);

      expect(res!.arguments['output-dir'], equals('build/'));
    });

    test('supports short option with inline equals (-n=value)', () {
      final resolver = CommandResolver(tree);
      final res = resolver.resolve(['create', '-o=build/', 'proj']);

      expect(res!.arguments['output-dir'], equals('build/'));
    });

    test('supports combined short flags (-rf)', () {
      final resolver = CommandResolver(tree);
      final res = resolver.resolve(['create', '-rf', 'proj']);

      expect(res!.flags['recursive'], isTrue);
      expect(res.flags['force'], isTrue);
    });

    test('supports flag negation (--no-flag)', () {
      final resolver = CommandResolver(tree);
      final res = resolver.resolve(['create', '--no-recursive', 'proj']);

      expect(res!.flags['recursive'], isFalse);
    });

    test(
        'throws FlagCannotBeNegatedException when negating a non-negatable flag',
        () {
      final resolver = CommandResolver(tree);
      expect(
        () => resolver.resolve(['create', '--no-force', 'proj']),
        throwsA(isA<FlagCannotBeNegatedException>()),
      );
    });

    test('applies default value for options when not provided', () {
      final resolver = CommandResolver(tree);
      final res = resolver.resolve(['create', 'proj']);

      expect(res!.arguments['output-dir'], equals('lib/'));
    });

    test('applies default flag when appliedByDefault is true', () {
      final resolver = CommandResolver(tree);
      final res = resolver.resolve(['create', 'proj']);

      expect(res!.flags['auto-format'], isTrue);
    });

    test('handles flags before and after positional arguments', () {
      final resolver = CommandResolver(tree);
      final res = resolver.resolve(['create', '-r', 'proj', '-f']);

      expect(res!.flags['recursive'], isTrue);
      expect(res.flags['force'], isTrue);
      expect(res.arguments['target'], equals('proj'));
    });

    test('handles option values that match command names', () {
      final resolver = CommandResolver(tree);
      final res = resolver
          .resolve(['create', '--output-dir', 'create', 'target_create']);

      expect(res!.arguments['output-dir'], equals('create'));
      expect(res.arguments['target'], equals('target_create'));
    });

    test(
        'throws MissingArgumentValueException when option value is missing at end of input',
        () {
      final resolver = CommandResolver(tree);
      expect(
        () => resolver.resolve(['create', '--output-dir']),
        throwsA(isA<MissingArgumentValueException>()),
      );
    });

    test(
        'throws MissingArgumentValueException when option value is followed by another option',
        () {
      final resolver = CommandResolver(tree);
      expect(
        () => resolver.resolve(['create', '--output-dir', '--force', 'proj']),
        throwsA(isA<MissingArgumentValueException>()),
      );
    });

    test('supports -- delimiter to terminate option parsing', () {
      final resolver = CommandResolver(tree);
      final res =
          resolver.resolve(['create', 'proj', '--', '--not-an-option', '-x']);

      expect(res!.arguments['target'], equals('proj'));
      expect(res.rest, equals(['--not-an-option', '-x']));
    });

    test(
        'throws UnknownOptionException for unrecognized long and short options',
        () {
      final resolver = CommandResolver(tree);
      expect(
        () => resolver.resolve(['create', '--unknown', 'proj']),
        throwsA(isA<UnknownOptionException>()),
      );
      expect(
        () => resolver.resolve(['create', '-z', 'proj']),
        throwsA(isA<UnknownOptionException>()),
      );
    });
  });
}
