/// Art fonts specific to the ASCII format
enum AsciiFont {
  cosmic,
  slant,
  rectangles,
}

extension AsciiFontsExtension on AsciiFont {
  String get path => '../../../assets/${name.toLowerCase()}.flf';
}
