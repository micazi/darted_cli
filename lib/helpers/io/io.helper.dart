import '../../models/console/styling/styling_models.exports.dart';
import './directory/directory.helper.dart';
import './file/file.helper.dart';
import 'methods/list_tree.dart';

class IOHelper {
  static DirectoryHelper directory = DirectoryHelper();
  static FileHelper file = FileHelper();

  /// Lists all the directories & files in the give directory path.
  Future<void> list(
    String path, {
    ConsoleColor? separatorColor,
    ConsoleColor? folderColor,
    ConsoleColor? fileColor,
  }) async =>
      await listTree(
        path,
        separatorColor: separatorColor?.textCode,
        fileColor: fileColor?.textCode,
        folderColor: folderColor?.textCode,
      );
}
