import 'dart:async';

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
