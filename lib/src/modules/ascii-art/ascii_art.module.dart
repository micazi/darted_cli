import 'package:enough_ascii_art/enough_ascii_art.dart' as art;
import '../../console/models/console_models.exports.dart';
import '../../io/helper/io.helper.dart';
import 'src/src.exports.dart';
import 'dart:io';
//
export 'src/src.exports.dart';

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
    File? file;
    if (customFontPath != null) {
      file = File(
          "${IOHelper.directory.getCurrent()}${Platform.pathSeparator}$customFontPath");
    } else {
      final fontFileUri = await font.path;
      if (fontFileUri != null) {
        file = File.fromUri(fontFileUri);
      }
    }
    //
    String? fileText = await file?.readAsString();

    if (fileText == null) {
      throw "ASCII art font file parsing failed, make sure the path is correct..";
    }
    String artText = art.renderFiglet(text, art.Font.text(fileText));
    // Split the art into lines
    final lines = artText.split('\n');
    // Prepend the character to each line
    final updatedLines = lines
        .map((line) =>
            '$beforeEachLine${line.withColor(color ?? ConsoleColor.grey)}')
        .toList();
    // Join the updated lines back into a single string
    artText = updatedLines.join('\n');
    return '$artText\n$beforeEachLine';
  }
}
