import 'dart:io';

List<int> chooseImpl(
  String prompt,
  List<String> options, {
  bool isMultiSelect = false,
  String selectedIndicator = "[x]",
  String unselectedIndicator = "[ ]",
  String selectionIndicator = "->",
}) {
  // vars
  int currentIndex = 0;
  List<bool> selected = List.generate(options.length, (_) => false);

  // Hide cursor
  stdout.write('\x1B[?25l');

  // Listen for user input
  stdin.echoMode = false;
  stdin.lineMode = false;

  // Draw the menu initially.
  drawMenu(prompt, options, selected, currentIndex, selectedIndicator,
      unselectedIndicator, selectionIndicator);

  // Loop through, listen for changes, and rebuild.
  while (true) {
    int input = stdin.readByteSync();
    switch (input) {
      case 27: // Escape sequences
        if (stdin.readByteSync() == 91) {
          final arrowKey = stdin.readByteSync();
          if (arrowKey == 65) currentIndex = moveUp(currentIndex, options);
          if (arrowKey == 66) currentIndex = moveDown(currentIndex, options);
        }
        break;
      case 32: // Spacebar
        selected = toggleSelect(selected, currentIndex, options, isMultiSelect);
        break;
      case 13: // Enter (carriage return)
      case 10: // Enter (newline)
        if (!isMultiSelect && selected.every((s) => !s)) {
          // Automatically select the current index if nothing was toggled...
          selected.fillRange(0, options.length, false);
          selected[currentIndex] = true;
        }

        // Cleanup the terminal..
        cleanup();

        // Write a space..
        stdout.writeln();

        // Return the selections..
        return List<int>.generate(options.length, (i) => selected[i] ? i : -1)
            .where((index) => index != -1)
            .toList();
    }

    // Redraw the menu.
    drawMenu(prompt, options, selected, currentIndex, selectedIndicator,
        unselectedIndicator, selectionIndicator);
  }
}

// Retuns the new index after moving up.
int moveUp(int currentIndex, List<String> options) {
  return (currentIndex - 1 + options.length) % options.length;
}

// Retuns the new index after moving down.
int moveDown(int currentIndex, List<String> options) {
  return (currentIndex + 1) % options.length;
}

// Retuns the new selected options after manipulating the toggling effect.
List<bool> toggleSelect(List<bool> selected, int currentIndex,
    List<String> options, bool isMultiSelect) {
  if (isMultiSelect) {
    selected[currentIndex] = !selected[currentIndex];
    return selected;
  } else {
    selected.fillRange(0, options.length, false);
    selected[currentIndex] = true;
    return selected;
  }
}

// Cleans up the terminal
void cleanup() {
  // Restore cursor and terminal settings
  stdout.write('\x1B[?25h');
  stdin.echoMode = true;
  stdin.lineMode = true;
}

void drawMenu(
    String prompt,
    List<String> options,
    List<bool> selected,
    int currentIndex,
    String selectedIndicator,
    String unselectedIndicator,
    String selectionIndicator) {
  // Clear the terminal
  stdout.write("\x1B[2J\x1B[H");

  // Display prompt
  stdout.writeln(prompt);

  // Display options
  for (int i = 0; i < options.length; i++) {
    final indicator = selected[i] ? selectedIndicator : unselectedIndicator;
    final pointer = i == currentIndex
        ? selectionIndicator
        : List.generate(selectionIndicator.length, (x) => ' ').join();
    stdout.writeln('$pointer $indicator ${options[i]}');
  }
}
