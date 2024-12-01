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

class TerminalHelper {
  /// Prompts the user to choose an option using arrow keys with an arrow indicator.
  /// [allowMultiple]: If true, allows selecting multiple options.
  /// Returns a list of selected options.
  static List<String> chooseImpl(
    String message,
    List<String> options, {
    bool allowMultiple = false,
  }) {
    // Hide the cursor
    stdout.write('\x1B[?25l');

    // Print the message
    stdout.writeln(message);
    stdout.writeln('Use ↑/↓ arrows to navigate, Space to select, and Enter to confirm.\n');

    int currentSelection = 0;
    final selectedIndices = <int>{};

    void renderOptions() {
      for (int i = 0; i < options.length; i++) {
        final isSelected = selectedIndices.contains(i);
        final isHighlighted = i == currentSelection;

        final indicator = isHighlighted ? '→' : ' ';
        final checkbox = isSelected ? '[x]' : '[ ]';

        stdout.write('\x1B[2K'); // Clear the line
        stdout.writeln('$indicator $checkbox ${options[i]}');
      }
    }

    void updateOption(int index, bool highlight, bool selected) {
      stdout.write('\x1B[${index + 3}H'); // Move the cursor to the specific line
      final indicator = highlight ? '→' : ' ';
      final checkbox = selected ? '[x]' : '[ ]';

      stdout.write('\x1B[2K'); // Clear the line
      stdout.write('$indicator $checkbox ${options[index]}');
    }

    // Save initial cursor position and render options
    stdout.write('\x1B[s'); // Save cursor position
    renderOptions();

    // Read user input
    stdin.echoMode = false;
    stdin.lineMode = false;
    while (true) {
      final key = stdin.readByteSync();
      if (key == 27) {
        final nextKey1 = stdin.readByteSync();
        final nextKey2 = stdin.readByteSync();

        // Arrow keys
        if (nextKey1 == 91 && nextKey2 == 65) {
          // Up Arrow
          final previousSelection = currentSelection;
          currentSelection = (currentSelection - 1) % options.length;
          if (currentSelection < 0) currentSelection += options.length; // Wrap around
          updateOption(previousSelection, false, selectedIndices.contains(previousSelection));
          updateOption(currentSelection, true, selectedIndices.contains(currentSelection));
        } else if (nextKey1 == 91 && nextKey2 == 66) {
          // Down Arrow
          final previousSelection = currentSelection;
          currentSelection = (currentSelection + 1) % options.length;
          updateOption(previousSelection, false, selectedIndices.contains(previousSelection));
          updateOption(currentSelection, true, selectedIndices.contains(currentSelection));
        }
      } else if (key == 32 && allowMultiple) {
        // Space key for selecting/deselecting
        if (selectedIndices.contains(currentSelection)) {
          selectedIndices.remove(currentSelection);
        } else {
          selectedIndices.add(currentSelection);
        }
        updateOption(currentSelection, true, selectedIndices.contains(currentSelection));
      } else if (key == 10) {
        // Enter key to confirm
        stdin.echoMode = true;
        stdin.lineMode = true;

        // Show the cursor
        stdout.write('\x1B[?25h');

        stdout.write('\x1B[u'); // Restore cursor position
        stdout.write('\x1B[J'); // Clear from cursor to end of screen

        if (allowMultiple) {
          return selectedIndices.map((index) => options[index]).toList();
        } else {
          return [options[currentSelection]];
        }
      }
    }
  }
}
