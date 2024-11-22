import 'dart:io';

/// Clear the console's window and reset the cursor to the top left.
void clearImpl() {
  stdout.write('\x1B[2J'); // Clear the screen
  stdout.write('\x1B[H'); // Move the cursor to the top-left corner
}
