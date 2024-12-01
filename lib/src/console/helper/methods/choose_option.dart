// import 'package:dart_console/dart_console.dart';
// import '../../../../console_helper.dart';

// List<String> chooseImpl(
//   String promptMessage,
//   List<String> options, {
//   bool allowMultiple = false,
// }) {
//   // Console-helping
//   final console = Console();
//   // Hide the cursor before user input
//   console.hideCursor();

//   // Clear screen and display the message
//   console.clearScreen();
//   console.writeLine(promptMessage);

//   int currentSelection = 0;
//   final selectedIndices = <int>{}; // To track selected options in multi-select

//   void renderOptions() {
//     for (int i = 0; i < options.length; i++) {
//       console.cursorPosition = Coordinate(i + 3, 0); // Adjust position for options

//       final isSelected = selectedIndices.contains(i);
//       final isHighlighted = i == currentSelection;

//       final indicator = isHighlighted ? '→' : ' '; // Arrow for current option
//       final checkbox = isSelected ? '[x]' : '[ ]'; // Checkbox for selection

//       console.writeLine('$indicator $checkbox ${options[i]}');
//     }
//   }

//   void updateOption(int index, bool highlight, bool selected) {
//     console.cursorPosition = Coordinate(index + 3, 0); // Adjust position for options

//     final indicator = highlight ? '→' : ' ';
//     final checkbox = selected ? '[x]' : '[ ]';

//     console.writeLine('$indicator $checkbox ${options[index]}');
//   }

//   // Initial render
//   renderOptions();

//   while (true) {
//     final key = console.readKey();

//     if (key.controlChar == ControlCharacter.arrowUp) {
//       final previousSelection = currentSelection;
//       currentSelection = (currentSelection - 1) % options.length;
//       if (currentSelection < 0) currentSelection += options.length; // Wrap around
//       updateOption(previousSelection, false, selectedIndices.contains(previousSelection));
//       updateOption(currentSelection, true, selectedIndices.contains(currentSelection));
//     } else if (key.controlChar == ControlCharacter.arrowDown) {
//       final previousSelection = currentSelection;
//       currentSelection = (currentSelection + 1) % options.length;
//       updateOption(previousSelection, false, selectedIndices.contains(previousSelection));
//       updateOption(currentSelection, true, selectedIndices.contains(currentSelection));
//     } else if (allowMultiple && key.char == ' ') {
//       if (selectedIndices.contains(currentSelection)) {
//         selectedIndices.remove(currentSelection);
//       } else {
//         selectedIndices.add(currentSelection);
//       }
//       updateOption(currentSelection, true, selectedIndices.contains(currentSelection));
//     } else if (key.controlChar == ControlCharacter.enter) {
//       ConsoleHelper.writeSpace();
//       // Show cursor after selection is complete
//       console.showCursor();

//       if (allowMultiple) {
//         return selectedIndices.map((index) => options[index]).toList();
//       } else {
//         return [options[currentSelection]];
//       }
//     }
//   }
// }

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
        cleanup();
        stdout.writeln();
        return List<int>.generate(options.length, (i) => selected[i] ? i : -1).where((index) => index != -1).toList();
    }
    drawMenu();
  }
}
