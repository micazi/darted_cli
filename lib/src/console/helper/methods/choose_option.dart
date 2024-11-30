import 'package:dart_console/dart_console.dart';

List<String> promptForOptionWithArrows(
  String message,
  List<String> options, {
  bool allowMultiple = false,
}) {
  final console = Console();
  //
  console.clearScreen();
  console.resetCursorPosition();
  console.writeLine(message);
  console.writeLine('Use ↑/↓ arrows to navigate, Space to select, and Enter to confirm.');
  console.writeLine('');

  int currentSelection = 0;
  final selectedIndices = <int>{}; // Tracks indices of selected options

  while (true) {
    // Display options with current selection highlighted
    for (var i = 0; i < options.length; i++) {
      final isSelected = selectedIndices.contains(i);
      if (i == currentSelection) {
        console.setForegroundColor(ConsoleColor.white);
        console.setBackgroundColor(ConsoleColor.blue);
        console.write(isSelected ? '[x] ' : '[ ] ');
        console.writeLine(options[i]);
        console.resetColorAttributes();
      } else {
        console.write(isSelected ? '[x] ' : '[ ] ');
        console.writeLine(options[i]);
      }
    }

    // Wait for user input
    final key = console.readKey();

    if (key.controlChar == ControlCharacter.arrowUp) {
      currentSelection = (currentSelection - 1) % options.length;
      if (currentSelection < 0) currentSelection += options.length; // Wrap around
    } else if (key.controlChar == ControlCharacter.arrowDown) {
      currentSelection = (currentSelection + 1) % options.length;
    } else if (allowMultiple && key.char == ' ') {
      // Toggle selection for multi-select
      if (selectedIndices.contains(currentSelection)) {
        selectedIndices.remove(currentSelection);
      } else {
        selectedIndices.add(currentSelection);
      }
    } else if (key.controlChar == ControlCharacter.enter) {
      if (allowMultiple) {
        // For multi-select, return all selected options
        return selectedIndices.map((index) => options[index]).toList();
      } else {
        // For single-select, return the currently selected option
        return [options[currentSelection]];
      }
    }

    // Clear screen and re-render options
    console.cursorUp();
  }
}
