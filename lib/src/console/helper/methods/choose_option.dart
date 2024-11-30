import 'package:dart_console/dart_console.dart';

final console = Console();
List<String> promptForOptionWithArrows(
  String message,
  List<String> options, {
  bool allowMultiple = false,
}) {
  //
  // Clear screen and display the message
  console.clearScreen();
  console.writeLine(message);
  console.writeLine('Use ↑/↓ arrows to navigate, Space to select, and Enter to confirm.\n');

  int currentSelection = 0;
  final selectedIndices = <int>{}; // To track selected options in multi-select

  void renderOptions() {
    for (int i = 0; i < options.length; i++) {
      console.cursorPosition = Coordinate(i + 3, 0); // Adjust position for options
      if (i == currentSelection) {
        // Highlight current selection
        console.setForegroundColor(ConsoleColor.white);
        console.setBackgroundColor(ConsoleColor.blue);
      } else {
        // Normal option
        console.resetColorAttributes();
      }

      final isSelected = selectedIndices.contains(i);
      console.writeLine('${isSelected ? "[x]" : "[ ]"} ${options[i]}');
    }
    console.resetColorAttributes(); // Reset after rendering
  }

  void updateOption(int index, bool highlight, bool selected) {
    console.cursorPosition = Coordinate(index + 3, 0); // Adjust for options
    if (highlight) {
      console.setForegroundColor(ConsoleColor.white);
      console.setBackgroundColor(ConsoleColor.blue);
    } else {
      console.resetColorAttributes();
    }
    console.writeLine('${selected ? "[x]" : "[ ]"} ${options[index]}');
    console.resetColorAttributes();
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
      if (allowMultiple) {
        return selectedIndices.map((index) => options[index]).toList();
      } else {
        return [options[currentSelection]];
      }
    }
  }
}
