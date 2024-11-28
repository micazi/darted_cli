import '../models/console_models.exports.dart';
import 'methods/methods.exports.dart';
//

class ConsoleHelper {
  /// Ask for user input asynchronously, You can add a timeout period and a default value (When the timeout runs or when he enters an empty value).
  static Future<String> getUserInput({
    required String Function(String?, int?) promptBuilder,
    String? defaultValue,
    Duration? timeOut,
  }) async =>
      await getUserInputImpl(promptBuilder,
          defaultValue: defaultValue, timeOut: timeOut);

  /// Write text to the console, You can use styling extension like [.withColor() and .withAlignment()]
  static void write(String text,
          {bool newLine = false, bool overwrite = false}) =>
      writeImpl(text, newLine: newLine, overwrite: overwrite);

  /// Write a new empty line to the console
  static void writeSpace() => writeSpaceImpl();

  /// Write a map of keys and values with justification of the values.
  static List<String> justifyMap(
    Map<String, String> map, {
    String preKey = '',
    int gapSeparatorSize = 8,
    String postValue = '',
  }) =>
      justifyMapImpl(
        map,
        preKey: preKey,
        gapSeparatorSize: gapSeparatorSize,
        postValue: postValue,
      );

  /// Confirm the user's choice with an affirmative keywork or a negative keyword, mostly (yes/no).
  static Future<bool> confirm(
          {String? prompt, List<String>? acceptedAffirmatives}) async =>
      await confirmImpl(
          prompt: prompt, acceptedAffirmatives: acceptedAffirmatives);

  /// Supply a task and a process future for that task, and show a beautiful loader till the task is finished. You can also customize a replacement output when it's done.
  static Future<void> loadWithTask({
    required String task,
    required Future Function() process,
    //
    ConsoleLoader? loader,
    ConsoleColor? loaderColor,
    Duration? loaderSpeed,
    LoaderPosition? loaderPosition,
    String? loaderSuccessReplacement,
    //
    ConsoleLoaderBase? customLoader,
  }) async =>
      await loadWithTaskImpl(
        task: task,
        process: process,
        loader: loader ?? ConsoleLoader.spinner,
        loaderColor: loaderColor ?? ConsoleColor.cyan,
        loaderSpeed: loaderSpeed ?? const Duration(milliseconds: 100),
        loaderPosition: loaderPosition ?? LoaderPosition.before,
        loaderSuccessReplacement:
            loaderSuccessReplacement ?? '✓'.withColor(ConsoleColor.green),
        customLoader: customLoader,
      );

  /// Clear the console's window and reset the cursor to the top left.
  static void clear() => clearImpl();

  /// Execute a terminal command (Return the output if exists).
  static Future<dynamic> executeCommand(String command) async =>
      await executeCommandImpl(command);

  /// Exit the console session.
  static void exit(int code,
          {bool withNewLine = true, bool withClearing = false}) =>
      exitImpl(code, withNewLine: withNewLine, withClearing: withClearing);
}
