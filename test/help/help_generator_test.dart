import 'package:darted_cli/darted_cli.dart';
import 'package:test/test.dart';

void main() {
  group('Help & Version Handling', () {
    late List<DartedCommand> tree;

    setUp(() {
      tree = [
        DartedCommand(
          name: 'init',
          helperDescription: 'Initialize a new project',
          callback: (_, __) {},
          arguments: [
            DartedArgument(
              name: 'template',
              abbreviation: 't',
              defaultValue: 'basic',
              description: 'Project template to use',
            ),
            DartedArgument(
              name: 'project-name',
              abbreviation: 'n',
              isMainReq: true,
              description: 'The name of the new project',
            ),
          ],
          flags: [
            DartedFlag(
              name: 'git',
              abbreviation: 'g',
              canBeNegated: true,
              description: 'Initialize a git repository',
            ),
          ],
          subCommands: [
            DartedCommand(
              name: 'plugin',
              helperDescription: 'Initialize a plugin',
              callback: (_, __) {},
            ),
          ],
        ),
      ];
    });

    test('generates root help when no arguments are provided', () async {
      final result = await dartedExecute(
        commandsTree: tree,
        input: [],
      );

      expect(result.isSuccess, isTrue);
      expect(result.exitCode, equals(0));
      expect(result.message, contains('Available Commands:'));
      expect(result.message, contains('init'));
      expect(result.message, contains('Initialize a new project'));
      expect(result.message, contains('Global Flags:'));
      expect(result.message, contains('--help, -h'));
    });

    test('generates root help on -h and --help at root level', () async {
      final res1 = await dartedExecute(commandsTree: tree, input: ['-h']);
      expect(res1.isSuccess, isTrue);
      expect(res1.message, contains('Available Commands:'));

      final res2 = await dartedExecute(commandsTree: tree, input: ['--help']);
      expect(res2.isSuccess, isTrue);
      expect(res2.message, contains('Available Commands:'));
    });

    test('generates subcommand-specific help on command --help', () async {
      final result = await dartedExecute(
        commandsTree: tree,
        input: ['init', '--help'],
      );

      expect(result.isSuccess, isTrue);
      expect(result.message, contains('init'));
      expect(result.message, contains('Initialize a new project'));
      expect(result.message, contains('Available Arguments:'));
      expect(result.message, contains('--template,-t [default: basic]'));
      expect(result.message, contains('Available Flags:'));
      expect(result.message, contains('--git,-g'));
      expect(result.message, contains('Available Sub-commands:'));
      expect(result.message, contains('plugin'));
    });

    test('help request bypasses required argument validation', () async {
      // 'init' requires positional 'project-name', but --help is requested
      final result = await dartedExecute(
        commandsTree: tree,
        input: ['init', '-h'],
      );

      expect(result.isSuccess, isTrue);
      expect(result.exitCode, equals(0));
      expect(result.message, contains('init'));
      expect(result.message, contains('Initialize a new project'));
    });

    test('generates version message on -v and --version', () async {
      final res1 = await dartedExecute(commandsTree: tree, input: ['-v']);
      expect(res1.isSuccess, isTrue);
      expect(res1.message, contains('Current installed version:'));

      final res2 =
          await dartedExecute(commandsTree: tree, input: ['--version']);
      expect(res2.isSuccess, isTrue);
      expect(res2.message, contains('Current installed version:'));
    });

    test('supports custom help and version response callbacks', () async {
      final resHelp = await dartedExecute(
        commandsTree: tree,
        input: ['init', '--help'],
        customHelpResponse: (cmd) => 'Custom Help for ${cmd.name}',
      );
      expect(resHelp.message, equals('Custom Help for init'));

      final resVer = await dartedExecute(
        commandsTree: tree,
        input: ['--version'],
        customVersionResponse: () => 'Custom Version: 9.9.9',
      );
      expect(resVer.message, equals('Custom Version: 9.9.9'));
    });
  });
}
