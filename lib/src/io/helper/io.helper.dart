import 'dart:io';
import '../../console/models/console_models.exports.dart';
import 'directory/directory.helper.dart';
import 'file/file.helper.dart';
import 'shared/list_tree.dart';
//
export './directory/directory.helper.dart';
export './file/file.helper.dart';
export 'shared/shared_methods.exports.dart';

class IOHelper {
  static DirectoryHelper directory = DirectoryHelper();
  static FileHelper file = FileHelper();

  /// Lists all the directories & files in the give directory path.
  static Future<void> list({
    String? path,
    ConsoleColor? separatorColor,
    ConsoleColor? folderColor,
    ConsoleColor? fileColor,
    //
    bool? withHiddenDirectories,
    bool? withHiddenFiles,
  }) async =>
      await listTree(
        path?.replaceSeparator() ?? IOHelper.directory.getCurrent(),
        separatorColor: separatorColor?.textCode ?? ConsoleColor.white.textCode,
        fileColor: fileColor?.textCode ?? ConsoleColor.blue.textCode,
        folderColor: folderColor?.textCode ?? ConsoleColor.magenta.textCode,
        //
        withHiddenDirectories: withHiddenDirectories ?? false,
        withHiddenFiles: withHiddenFiles ?? true,
      );
}

extension PathSeparatorExtension on String {
  String replaceSeparator() =>
      replaceAll(RegExp(r'[\\/]+'), Platform.pathSeparator);
}
