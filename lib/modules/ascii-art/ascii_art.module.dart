import 'dart:io';
import '../../helpers/style_extension.helper.dart';
import 'package:enough_ascii_art/enough_ascii_art.dart' as art;
import 'fonts/index.dart';
//
export './fonts/index.dart';

class AsciiArtModule {
  /// Convert text to Ascii art with customizable fonts. Custom fonts must be a .flf file.
  static Future<String> textToAscii(
    String text, {
    AsciiFont font = AsciiFont.slant,
    String? customFontPath,
    String beforeEachLine = '',
    ConsoleColor? color,
  }) async {
    //
    String fontFile = await File(customFontPath ?? font.path).readAsString();
    String artText = art.renderFiglet(text, art.Font.text(fontFile));
    // Split the art into lines
    final lines = artText.split('\n');
    // Prepend the character to each line
    final updatedLines = lines.map((line) => '$beforeEachLine${line.withColor(color ?? ConsoleColor.grey)}').toList();
    // Join the updated lines back into a single string
    artText = updatedLines.join('\n');
    return '$artText\n$beforeEachLine';
  }
}
