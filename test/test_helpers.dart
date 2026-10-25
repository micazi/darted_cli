import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Captures all prints executed during [fn].
Future<List<String>> capturePrint(FutureOr<void> Function() fn) async {
  final logs = <String>[];
  final spec = ZoneSpecification(
    print: (self, parent, zone, line) {
      logs.add(line);
    },
  );
  await Zone.current.fork(specification: spec).run(fn);
  return logs;
}

class _SilentStdout implements Stdout {
  @override
  final Encoding encoding = utf8;

  @override
  bool get hasTerminal => false;

  @override
  int get terminalColumns => 80;

  @override
  int get terminalLines => 25;

  @override
  bool get supportsAnsiEscapes => false;

  @override
  void add(List<int> data) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream<List<int>> stream) => stream.drain();

  @override
  Future close() async {}

  @override
  Future get done => Future.value();

  @override
  Future flush() => Future.value();

  @override
  void write(Object? object) {}

  @override
  void writeAll(Iterable objects, [String separator = '']) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object? object = '']) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Runs [fn] with stdout silenced so CLI feedback does not pollute the test runner.
Future<T> runSilently<T>(Future<T> Function() fn) {
  return IOOverrides.runZoned(fn, stdout: () => _SilentStdout());
}
