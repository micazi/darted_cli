import 'package:dart_console/dart_console.dart';

final console = Console();
List<String> promptForOptionWithArrows(
  String message,
  List<String> options, {
  bool allowMultiple = false,
}) {
  //
  console.clearScreen();
  console.resetCursorPosition();
  console.writeLine(message);
  console.writeLine('Use ↑/↓ arrows to navigate, Space to select, and Enter to confirm.');
  console.writeLine('');

  int currentSelection = 0;
  final selectedIndices = <int>{}; // Tracks indices of selected options

  // Initial rendering of options
  for (var i = 0; i < options.length; i++) {
    _renderOption(i, options[i], selected: selectedIndices.contains(i), highlight: i == currentSelection);
  }

  while (true) {
    // Wait for user input
    final key = console.readKey();

    int previousSelection = currentSelection;

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
      _renderOption(currentSelection, options[currentSelection], selected: selectedIndices.contains(currentSelection), highlight: true);
    } else if (key.controlChar == ControlCharacter.enter) {
      if (allowMultiple) {
        // For multi-select, return all selected options
        return selectedIndices.map((index) => options[index]).toList();
      } else {
        // For single-select, return the currently selected option
        return [options[currentSelection]];
      }
    }

    // Update only the previous and current selections
    if (previousSelection != currentSelection) {
      _renderOption(previousSelection, options[previousSelection], selected: selectedIndices.contains(previousSelection), highlight: false);
      _renderOption(currentSelection, options[currentSelection], selected: selectedIndices.contains(currentSelection), highlight: true);
    }
  }
}

/// Renders a single option at the current cursor position.
void _renderOption(int index, String option, {required bool selected, required bool highlight}) {
  console.cursorPosition = Coordinate((console.cursorPosition?.row ?? 0) - index, 0);
  if (highlight) {
    console.setForegroundColor(ConsoleColor.white);
    console.setBackgroundColor(ConsoleColor.blue);
  }
  console.write(selected ? '[x] ' : '[ ] ');
  console.writeLine(option);
  if (highlight) {
    console.resetColorAttributes();
  }
}
