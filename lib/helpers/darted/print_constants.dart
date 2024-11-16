import '../../models/models.exports.dart';

import '../../modules/modules.exports.dart';
import '../helpers.exports.dart';

const String startPrint = """|-------""";
const String endPrint = """|-------""";
//
//----------------
//
defaultHelperMessage(DartedCommand command) {
  //
  bool hasSubCommands = command.subCommands != null && command.subCommands!.isNotEmpty;
  Map<String, String> subCommandsHelpersMap = Map.fromEntries(command.subCommands?.map((s) => MapEntry(s.name, s.helperDescription ?? 'No Helper Message.')).toList() ?? []);
  String? justifiedCommands = hasSubCommands && subCommandsHelpersMap.isNotEmpty ? ConsoleHelper.justifyMap(subCommandsHelpersMap, gapSeparatorSize: 8, preKey: '| ').reduce((a, b) => "$a\n$b") : null;
  String helperDescription = command.helperDescription != null ? '${command.helperDescription!.withColor(ConsoleColor.blue).withTextStyle(ConsoleTextModifier.italic)}\n|' : '';
  String titleAndHelperMessage = """
$startPrint
|
| This is the help message of the ${command.name.withColor(ConsoleColor.cyan)} command.
| $helperDescription
""";

  String ending = """
|
|-------
""";
  //
  return titleAndHelperMessage +
      (hasSubCommands && justifiedCommands != null ? '$justifiedCommands\n' : '')
      //
      +
      ending;
}

Future<String> defaultVersionMessage() async {
  // scour for the pubspec.yaml
  String pubspecPath = await IOHelper.file.find(IOHelper.directory.getCurrent(), 'pubspec.yaml').then((v) => v.first);
  YamlMap pubspecContent = await YamlModule.load(pubspecPath);
  String packageName = pubspecContent['name'];
  String packageVersion = pubspecContent['version'];
  //

  String titleAndHelperMessage = """
|-------
|
| ${packageName.withColor(ConsoleColor.lightMagenta).withTextStyle(ConsoleTextModifier.underline)}
|
| Current installed version: $packageVersion
""";

  String ending = """
|
|-------
""";
  //
  return titleAndHelperMessage + ending;
}
