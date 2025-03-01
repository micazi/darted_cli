import '../../io/helper/io.helper.dart';
import '../../modules/yaml/yaml.module.dart';
import '../models/darted_models.exports.dart';
import '../../console/models/console_models.exports.dart';
import '../../console/helper/console.helper.dart';

const String startPrint = """|-------""";
const String endPrint = """|-------""";
//
//----------------
//
Future<String> defaultHelperMessage(DartedCommand command) async{
    String pubspecPath = await IOHelper.file.find(IOHelper.directory.getCurrent(), 'pubspec.yaml').then((v) => v.first);
  YamlMap pubspecContent = await YamlModule.load(pubspecPath);
  String packageName = pubspecContent['name'];
  //
  Map<String, String> argsList = Map.fromEntries(command.arguments
          ?.map((a) => MapEntry(
              "--${a?.name},-${a?.abbreviation} [default: ${a?.defaultValue ?? 'N/A'}]",
              a?.description?.withColor(ConsoleColor.grey) ?? ''))
          .toList() ??
      []);
  String? mainArg = command.arguments?.where((arg) => (arg?.isMainReq ?? false)).firstOrNull?.name;
    String helpDescription =
      "${command.name.withColor(ConsoleColor.cyan)} :- ${command.helperDescription}";
  String usage =
      "Usage: $packageName ${command.name} ${mainArg != null? '<$mainArg> ' : ''}[--argumentKey value] [--flag, --no-flag]";
  String availableArgsTitle = "Available Arguments:";
  String justifiedArgs = (command.arguments?.isNotEmpty ?? false)
      ? ConsoleHelper.justifyMap(argsList, gapSeparatorSize: 4)
          .reduce((a, b) => "$a\n| $b")
      : 'N/A'.withColor(ConsoleColor.lightRed);
  String availableFlagsTitle = "Available Flags:";
  Map<String, String> flagList = Map.fromEntries(command.flags
          ?.map((f) => MapEntry(
              "--${f.name},-${f.abbreviation}${f.canBeNegated ? '  (Negatable)'.withColor(ConsoleColor.magenta) : ''}${f.appliedByDefault ? '  (Defaultly applied)' : ''}",
              f.description?.withColor(ConsoleColor.grey) ?? ''))
          .toList() ??
      []);
  String justifiedFlags = (command.flags?.isNotEmpty ?? false)
      ? ConsoleHelper.justifyMap(flagList, gapSeparatorSize: 4)
          .reduce((a, b) => "$a\n| $b")
      : 'N/A'.withColor(ConsoleColor.lightRed);
  String availableCommandsTitle = "Available Sub-commands:";
  String justifiedCommands = (command.subCommands?.isNotEmpty ?? false)
      ? ConsoleHelper.justifyMap(Map.fromEntries(command.subCommands?.map((c) =>
                  MapEntry(
                      c.name,
                      c.helperDescription ??
                          'N/A'.withColor(ConsoleColor.lightRed))) ??
              []))
          .reduce((a, b) => "$a\n| $b")
      : 'N/A'.withColor(ConsoleColor.lightRed);
  return """
|======
|
| $helpDescription
| 
| $usage
|
| $availableArgsTitle
| $justifiedArgs
|
| $availableFlagsTitle
| $justifiedFlags
|
| $availableCommandsTitle
| $justifiedCommands
|
|======
""";
}

Future<String> defaultVersionMessage() async {
  // scour for the pubspec.yaml
  String pubspecPath = await IOHelper.file
      .find(IOHelper.directory.getCurrent(), 'pubspec.yaml')
      .then((v) => v.first);
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
