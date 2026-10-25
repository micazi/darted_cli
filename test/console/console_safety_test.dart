import 'package:darted_cli/console_helper.dart';
import 'package:darted_cli/src/console/helper/methods/choose_option.dart';
import 'package:test/test.dart';

import '../test_helpers.dart';

void main() {
  group('Console Safety & Reliability', () {
    test('withAlignment handles non-TTY and strips ANSI for padding width', () {
      final text = 'Hello'.withColor(ConsoleColor.cyan);
      final alignedCenter = text.withAlignment(ConsoleTextAlignment.center);
      expect(alignedCenter, contains('Hello'));

      final alignedRight = text.withAlignment(ConsoleTextAlignment.right);
      expect(alignedRight, contains('Hello'));

      final alignedLeft = text.withAlignment(ConsoleTextAlignment.left);
      expect(alignedLeft, equals(text));
    });

    test('loadWithTask prevents timer leaks when process throws an exception',
        () async {
      var exceptionThrown = false;

      try {
        await runSilently(
          () => ConsoleHelper.loadWithTask(
            task: 'Failing task',
            process: () async {
              await Future.delayed(const Duration(milliseconds: 10));
              throw const FormatException('Process failed on purpose');
            },
          ),
        );
      } catch (e) {
        exceptionThrown = true;
        expect(e, isA<FormatException>());
      }

      expect(exceptionThrown, isTrue);
    });

    test('chooseOption safely returns empty on empty options list', () {
      final result = ConsoleHelper.chooseOption('Pick', []);
      expect(result, isEmpty);
    });

    test('moveUp and moveDown wrap around cleanly', () {
      final options = ['A', 'B', 'C'];
      expect(moveUp(0, options), equals(2));
      expect(moveDown(2, options), equals(0));
      expect(moveUp(1, options), equals(0));
      expect(moveDown(1, options), equals(2));

      // Empty list edge case
      expect(moveUp(0, []), equals(0));
      expect(moveDown(0, []), equals(0));
    });

    test('toggleSelect works for single and multi select', () {
      final single = toggleSelect([false, false], 1, ['A', 'B'], false);
      expect(single, equals([false, true]));

      final multi1 = toggleSelect([false, false], 0, ['A', 'B'], true);
      expect(multi1, equals([true, false]));

      final multi2 = toggleSelect([true, false], 1, ['A', 'B'], true);
      expect(multi2, equals([true, true]));

      final multi3 = toggleSelect([true, true], 0, ['A', 'B'], true);
      expect(multi3, equals([false, true]));
    });
  });
}
