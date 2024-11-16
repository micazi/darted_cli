import 'dart:convert';
import 'dart:io';
import 'package:darted_cli/modules/ascii-art/fonts/index.dart';
import 'package:enough_ascii_art/enough_ascii_art.dart' as art;
//
export './fonts/index.dart';

class AsciiArtModule {
  static Future<String> textToAscii(String text, {AsciiFont font = AsciiFont.slant, String beforeEachLine = '| ', String afterEachLine = ''}) async {
    //
    String fontFile = await File(font.path).readAsString();
    //
    String artText = art.renderFiglet(
      text,
      art.Font.text(fontFile),
    );
    List<RegExpMatch> allBreaks = RegExp(r'\n').allMatches(artText).toList();
    // Replace the first
    artText = artText.replaceRange(allBreaks.first.start, allBreaks.first.end, '\r$beforeEachLine\n');
    // Replace all others
    for (var element in collection) {}
    artText = artText.replaceRange(allBreaks.sublist(1, allBreaks.length - 1).first.start, allBreaks.first.end, '$beforeEachLine\n');
    // Replace the last
    artText = artText.replaceRange(allBreaks.last.start, allBreaks.last.end, '\r$beforeEachLine\n');
    return artText;
  }
}

// asciiArt.replaceFirst('\n', '\r|\n').replaceAll('\n', '\n| ') 
