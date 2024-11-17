import 'get_user_input.dart';
import '../../style_extension.helper.dart';

/// Confirm the user's choice with an affirmative keywork or a negative keyword, mostly (yes/no).
Future<bool> confirmImpl(
    {String? prompt, List<String>? acceptedAffirmatives}) async {
  List<String> affirvatives = acceptedAffirmatives ?? ['yes', 'y'];
  String p = prompt ??
      'Are you sure?'.withColor(ConsoleColor.blue) +
          '(yes/no): '.withColor(ConsoleColor.grey);
  String userInput = await getUserInputImpl((defValue, timeout) => p);
  //
  return affirvatives
      .map((a) => a.toLowerCase().trim())
      .contains(userInput.toLowerCase().trim());
}
