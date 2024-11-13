import 'dart:io';

/// Write text to the console, You can use styling extension like [.withColor() and .withAlignment()]
writeImpl(String text, {bool newLine = false, bool overwrite = false}) {
  if (newLine) {
    stdout.writeln();
  }

  if (overwrite) {
    // Move the cursor to the beginning of the current line and overwrite it
    stdout.write('\x1B[2K'); // Clear current line
    stdout.write('\x1B[0G'); // Move cursor to the start of the line
  }

  stdout.write(text);
}

/// Write a new empty line to the console
writeSpaceImpl() => stdout.writeln();
