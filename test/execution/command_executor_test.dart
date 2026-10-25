import 'package:darted_cli/darted_cli.dart';
import 'package:test/test.dart';

void main() {
  group('Command Execution & Error Handling', () {
    test('executes synchronous command callback successfully', () async {
      var invoked = false;
      Map<String, dynamic>? receivedArgs;
      Map<String, bool>? receivedFlags;

      final tree = [
        DartedCommand(
          name: 'build',
          callback: (args, flags) {
            invoked = true;
            receivedArgs = args;
            receivedFlags = flags;
          },
          arguments: [
            DartedArgument(name: 'target', abbreviation: 't', isMainReq: true),
          ],
          flags: [
            DartedFlag(name: 'release', abbreviation: 'r'),
          ],
        ),
      ];

      final result = await dartedExecute(
        commandsTree: tree,
        input: ['build', 'web', '--release'],
      );

      expect(result.isSuccess, isTrue);
      expect(result.exitCode, equals(0));
      expect(invoked, isTrue);
      expect(receivedArgs?['target'], equals('web'));
      expect(receivedFlags?['release'], isTrue);
    });

    test('properly awaits asynchronous command callback', () async {
      var step = 0;

      final tree = [
        DartedCommand(
          name: 'async-task',
          callback: (args, flags) async {
            step = 1;
            await Future.delayed(const Duration(milliseconds: 10));
            step = 2;
          },
        ),
      ];

      final result = await dartedExecute(
        commandsTree: tree,
        input: ['async-task'],
      );

      expect(result.isSuccess, isTrue);
      expect(step, equals(2));
    });

    test(
        'returns structured failure and exit code 1 without terminating VM on validation error',
        () async {
      final tree = [
        DartedCommand(
          name: 'serve',
          callback: (_, __) {},
          arguments: [
            DartedArgument(name: 'port', abbreviation: 'p', isMainReq: true),
          ],
        ),
      ];

      final result = await dartedExecute(
        commandsTree: tree,
        input: ['serve'], // missing required positional 'port'
      );

      expect(result.isSuccess, isFalse);
      expect(result.exitCode, equals(1));
      expect(result.error, isA<MissingRequiredArgumentException>());
      expect(result.message, contains('Missing required positional argument'));
    });

    test('rethrows exception when throwOnError is true', () async {
      final tree = [
        DartedCommand(
          name: 'serve',
          callback: (_, __) {},
          arguments: [
            DartedArgument(name: 'port', abbreviation: 'p', isMainReq: true),
          ],
        ),
      ];

      expect(
        () => dartedExecute(
          commandsTree: tree,
          input: ['serve'],
          throwOnError: true,
        ),
        throwsA(isA<MissingRequiredArgumentException>()),
      );
    });

    test('uses custom error callbacks when provided', () async {
      var customInvoked = false;

      final tree = [
        DartedCommand(
          name: 'test-cmd',
          callback: (_, __) {},
        ),
      ];

      final result = await dartedExecute(
        commandsTree: tree,
        input: ['unknown-cmd'],
        customCommandInvalidError: (cmd, match) {
          customInvoked = true;
          return 'Custom Error: Command $cmd was not found!';
        },
      );

      expect(result.isSuccess, isFalse);
      expect(customInvoked, isTrue);
      expect(result.message,
          equals('Custom Error: Command unknown-cmd was not found!'));
    });

    test('captures unhandled exception inside callback without crashing VM',
        () async {
      final tree = [
        DartedCommand(
          name: 'crash',
          callback: (_, __) =>
              throw StateError('Something broke inside user callback'),
        ),
      ];

      final result = await dartedExecute(
        commandsTree: tree,
        input: ['crash'],
      );

      expect(result.isSuccess, isFalse);
      expect(result.exitCode, equals(1));
      expect(result.error, isA<StateError>());
      expect(result.message, contains('Something broke inside user callback'));
    });
  });
}
