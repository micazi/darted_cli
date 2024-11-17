import 'dart:isolate';

/// Art fonts specific to the ASCII format
enum AsciiFont {
  cosmic,
  slant,
  rectangles,
}

extension AsciiFontsExtension on AsciiFont {
  Future<Uri?> get path async {
    final packageUri = Uri.parse('package:darted_cli/modules/ascii-art/fonts/${name.toLowerCase()}.flf');
    Uri? futured = await Isolate.resolvePackageUri(packageUri);
    return futured;
  }
}
