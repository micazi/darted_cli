import 'package:dart_console/dart_console.dart';

import '../../../../console_helper.dart';

final console = Console();
List<String> promptForOptionWithArrows(
  String message,
  List<String> options, {
  bool allowMultiple = false,
}) {
  // Hide the cursor before user input
  console.hideCursor();

  // Clear screen and display the message
  console.clearScreen();
  console.writeLine(message);
  console.writeLine('Use ↑/↓ arrows to navigate, Space to select, and Enter to confirm.\n');

  int currentSelection = 0;
  final selectedIndices = <int>{}; // To track selected options in multi-select

  void renderOptions() {
    for (int i = 0; i < options.length; i++) {
      console.cursorPosition = Coordinate(i + 3, 0); // Adjust position for options

      final isSelected = selectedIndices.contains(i);
      final isHighlighted = i == currentSelection;

      final indicator = isHighlighted ? '→' : ' '; // Arrow for current option
      final checkbox = isSelected ? '[x]' : '[ ]'; // Checkbox for selection

      console.writeLine('$indicator $checkbox ${options[i]}');
    }
  }

  void updateOption(int index, bool highlight, bool selected) {
    console.cursorPosition = Coordinate(index + 3, 0); // Adjust position for options

    final indicator = highlight ? '→' : ' ';
    final checkbox = selected ? '[x]' : '[ ]';

    console.writeLine('$indicator $checkbox ${options[index]}');
  }

  // Initial render
  renderOptions();

  while (true) {
    final key = console.readKey();

    if (key.controlChar == ControlCharacter.arrowUp) {
      final previousSelection = currentSelection;
      currentSelection = (currentSelection - 1) % options.length;
      if (currentSelection < 0) currentSelection += options.length; // Wrap around
      updateOption(previousSelection, false, selectedIndices.contains(previousSelection));
      updateOption(currentSelection, true, selectedIndices.contains(currentSelection));
    } else if (key.controlChar == ControlCharacter.arrowDown) {
      final previousSelection = currentSelection;
      currentSelection = (currentSelection + 1) % options.length;
      updateOption(previousSelection, false, selectedIndices.contains(previousSelection));
      updateOption(currentSelection, true, selectedIndices.contains(currentSelection));
    } else if (allowMultiple && key.char == ' ') {
      if (selectedIndices.contains(currentSelection)) {
        selectedIndices.remove(currentSelection);
      } else {
        selectedIndices.add(currentSelection);
      }
      updateOption(currentSelection, true, selectedIndices.contains(currentSelection));
    } else if (key.controlChar == ControlCharacter.enter) {
      // Show cursor after selection is complete
      console.showCursor();

      if (allowMultiple) {
        return selectedIndices.map((index) => options[index]).toList();
      } else {
        return [options[currentSelection]];
      }
    }
  }
}
