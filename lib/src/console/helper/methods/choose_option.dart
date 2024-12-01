import 'dart:io';

bool _isMultiSelect = false;

/// Renders a selectable menu in the terminal.
/// - [title]: The menu title to display.
/// - [options]: List of options for the user to select.
/// - [multiSelect]: Allow selecting multiple options.
List<int> chooseImpl(String title, List<String> options, {bool multiSelect = false}) {
  _isMultiSelect = multiSelect;
  final selected = List.generate(options.length, (_) => false);
  int currentIndex = 0;

  void drawMenu() {
    // Clear the terminal
    stdout.write("\x1B[2J\x1B[H");

    // Display title
    stdout.writeln(title);
    stdout.writeln('\nUse ↑/↓ arrows to navigate, Space to select, and Enter to confirm.\n');

    // Display options
    for (int i = 0; i < options.length; i++) {
      final indicator = selected[i] ? '[x]' : '[ ]';
      final pointer = i == currentIndex ? '→' : ' ';
      stdout.writeln('$pointer $indicator ${options[i]}');
    }
  }

  // Hide cursor
  stdout.write('\x1B[?25l');

  // Listen for user input
  stdin.echoMode = false;
  stdin.lineMode = false;

  void moveUp() {
    currentIndex = (currentIndex - 1 + options.length) % options.length;
  }

  void moveDown() {
    currentIndex = (currentIndex + 1) % options.length;
  }

  void toggleSelect() {
    if (_isMultiSelect) {
      selected[currentIndex] = !selected[currentIndex];
    } else {
      selected.fillRange(0, options.length, false);
      selected[currentIndex] = true;
    }
  }

  void cleanup() {
    // Restore cursor and terminal settings
    stdout.write('\x1B[?25h');
    stdin.echoMode = true;
    stdin.lineMode = true;
  }

  drawMenu();
  while (true) {
    final input = stdin.readByteSync();

    switch (input) {
      case 27: // Escape sequences
        if (stdin.readByteSync() == 91) {
          final arrowKey = stdin.readByteSync();
          if (arrowKey == 65) moveUp(); // Arrow Up
          if (arrowKey == 66) moveDown(); // Arrow Down
        }
        break;
      case 32: // Spacebar
        toggleSelect();
        break;
      case 13: // Enter (carriage return)
      case 10: // Enter (newline)
        if (!_isMultiSelect && selected.every((s) => !s)) {
          // Automatically select the current index if nothing was toggled
          selected.fillRange(0, options.length, false);
          selected[currentIndex] = true;
        }
        cleanup();
        stdout.writeln();
        return List<int>.generate(options.length, (i) => selected[i] ? i : -1).where((index) => index != -1).toList();
    }
    drawMenu();
  }
}
