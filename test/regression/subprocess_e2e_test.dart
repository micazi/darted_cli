import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('Subprocess E2E Regression Tests', () {
    final dartBinary = Platform.resolvedExecutable;
    const scriptPath = 'example/bin/test_package.dart';

    test('invokes CLI with --version as subprocess', () async {
      final process = await Process.run(
        dartBinary,
        ['run', scriptPath, '--version'],
      );

      expect(process.exitCode, equals(0));
      expect(process.stdout.toString(),
          contains("when i get -v, here's a response!"));
    });

    test('invokes CLI with -h / --help as subprocess', () async {
      final process = await Process.run(
        dartBinary,
        ['run', scriptPath, 'create', '-h'],
      );

      expect(process.exitCode, equals(0));
      expect(process.stdout.toString(),
          contains('custom response for the -h flag?'));
    });

    test('invokes CLI with missing required positional and exits with code 1',
        () async {
      final process = await Process.run(
        dartBinary,
        ['run', scriptPath, 'create'],
      );

      expect(process.exitCode, equals(1));
      expect(process.stdout.toString(),
          contains('Missing required positional argument'));
    });

    test('invokes CLI with valid arguments and exits with code 0', () async {
      final process = await Process.run(
        dartBinary,
        [
          'run',
          scriptPath,
          'create',
          'my/custom/path',
          '--name',
          'hello_world'
        ],
      );

      expect(process.exitCode, equals(0));
      expect(process.stdout.toString(), contains('create'));
      expect(process.stdout.toString(), contains('my/custom/path'));
      expect(process.stdout.toString(), contains('hello_world'));
    });
  });
}
