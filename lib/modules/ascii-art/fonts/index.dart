/// Art fonts specific to the ASCII format
enum AsciiFont {
  cosmic,
  slant,
  rectangles,
}

extension AsciiFontsExtension on AsciiFont {
  String get path => 'package:darted_cli/lib/assets/${name.toLowerCase()}.flf';
}
