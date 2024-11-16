enum AsciiFont {
  cosmic,
  slant,
  rectangles,
}

extension AsciiFontsExtension on AsciiFont {
  String get path => './lib/modules/ascii-art/fonts/${name.toLowerCase()}.flf';
}
