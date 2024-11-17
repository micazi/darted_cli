/// Art fonts specific to the ASCII format
enum AsciiFont {
  cosmic,
  slant,
  rectangles,
}

extension AsciiFontsExtension on AsciiFont {
  String get path => 'packages/darted_cli/modules/ascii-art/fonts/${name.toLowerCase()}.flf';
}
