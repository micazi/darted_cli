import 'dart:async';
import 'dart:io';

List<int> chooseImpl(
  String prompt,
  List<String> options, {
  bool isMultiSelect = false,
  String selectedIndicator = "[x]",
  String unselectedIndicator = "[ ]",
  String selectionIndicator = "->",
}) {
  // 1. Validate empty selection menus
  if (options.isEmpty) {
    return <int>[];
  }

  // 2. Check for non-interactive / non-TTY environments
  try {
    if (!stdin.hasTerminal || !stdout.hasTerminal) {
      return isMultiSelect ? <int>[] : [0];
    }
  } catch (_) {
    return isMultiSelect ? <int>[] : [0];
  }

  int currentIndex = 0;
  List<bool> selected = List.generate(options.length, (_) => false);
  StreamSubscription? sigintSub;

  try {
    // 3. Handle interactive-menu cancellation safely via SIGINT hook
    try {
      sigintSub = ProcessSignal.sigint.watch().listen((_) {
        cleanup();
        exit(130);
      });
    } catch (_) {
      // ProcessSignal may not be supported on all platforms
    }

    // Hide cursor and switch to raw terminal mode
    stdout.write('\x1B[?25l');
    stdin.echoMode = false;
    stdin.lineMode = false;

    // Draw the menu initially
    drawMenu(
      prompt,
      options,
      selected,
      currentIndex,
      selectedIndicator,
      unselectedIndicator,
      selectionIndicator,
      isFirstDraw: true,
    );

    // Loop through, listen for changes, and rebuild
    while (true) {
      int input = stdin.readByteSync();
      switch (input) {
        case 3: // Ctrl+C (in raw mode)
          cleanup();
          exit(130);

        case 27: // Escape sequences or bare Escape
          // Arrow keys send 27, 91, 65/66
          final nextByte = stdin.readByteSync();
          if (nextByte == 91) {
            final arrowKey = stdin.readByteSync();
            if (arrowKey == 65) currentIndex = moveUp(currentIndex, options);
            if (arrowKey == 66) currentIndex = moveDown(currentIndex, options);
          } else {
            // Bare Escape: cancel selection
            return <int>[];
          }
          break;

        case 113: // 'q' - cancel
        case 81: // 'Q' - cancel
          return <int>[];

        case 32: // Spacebar
          selected =
              toggleSelect(selected, currentIndex, options, isMultiSelect);
          break;

        case 13: // Enter (carriage return)
        case 10: // Enter (newline)
          if (!isMultiSelect && selected.every((s) => !s)) {
            // Automatically select the current index if nothing was toggled
            selected.fillRange(0, options.length, false);
            selected[currentIndex] = true;
          }

          stdout.writeln();

          return List<int>.generate(options.length, (i) => selected[i] ? i : -1)
              .where((index) => index != -1)
              .toList();
      }

      // Redraw menu in-place without wiping terminal scrollback
      drawMenu(
        prompt,
        options,
        selected,
        currentIndex,
        selectedIndicator,
        unselectedIndicator,
        selectionIndicator,
        isFirstDraw: false,
      );
    }
  } finally {
    // 4. Guarantee terminal-state restoration using try/finally
    cleanup();
    sigintSub?.cancel();
  }
}

/// Returns the new index after moving up safely.
int moveUp(int currentIndex, List<String> options) {
  if (options.isEmpty) return 0;
  return (currentIndex - 1 + options.length) % options.length;
}

/// Returns the new index after moving down safely.
int moveDown(int currentIndex, List<String> options) {
  if (options.isEmpty) return 0;
  return (currentIndex + 1) % options.length;
}

/// Returns the new selected options after toggling.
List<bool> toggleSelect(
  List<bool> selected,
  int currentIndex,
  List<String> options,
  bool isMultiSelect,
) {
  if (isMultiSelect) {
    selected[currentIndex] = !selected[currentIndex];
    return selected;
  } else {
    selected.fillRange(0, options.length, false);
    selected[currentIndex] = true;
    return selected;
  }
}

/// Cleans up terminal state by restoring cursor and echo/line modes.
void cleanup() {
  try {
    stdout.write('\x1B[?25h');
    stdin.echoMode = true;
    stdin.lineMode = true;
  } catch (_) {
    // Ignore cleanup errors on non-standard streams
  }
}

/// Draws or updates the menu in-place without clearing entire terminal history.
void drawMenu(
  String prompt,
  List<String> options,
  List<bool> selected,
  int currentIndex,
  String selectedIndicator,
  String unselectedIndicator,
  String selectionIndicator, {
  bool isFirstDraw = false,
}) {
  if (!isFirstDraw) {
    // Move cursor up by prompt + options count
    stdout.write('\x1B[${options.length + 1}A');
  }

  // Clear current line and write prompt
  stdout.write('\x1B[2K\r');
  stdout.writeln(prompt);

  // Clear line and write each option
  for (int i = 0; i < options.length; i++) {
    final indicator = selected[i] ? selectedIndicator : unselectedIndicator;
    final pointer = i == currentIndex
        ? selectionIndicator
        : List.generate(selectionIndicator.length, (x) => ' ').join();
    stdout.write('\x1B[2K\r');
    stdout.writeln('$pointer $indicator ${options[i]}');
  }
}
