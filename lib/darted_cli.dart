// import 'package:darted_cli/helpers/console.helper.dart';

// import 'models/models.exports.dart';
// import 'package:darted_cli/helpers/helpers.exports.dart';
// //
// export 'models/models.exports.dart';
// export 'package:darted_cli/helpers/helpers.exports.dart';

// Future dartedEntry({
//   required List<DartedCommand> commandsTree,
//   required Future<Map<String, Function>> Function(CallbackHelper helper) callbackMapper,
// }) async {
//   //
//   final helper = CallbackHelper(commandStack: [], arguments: {}, flags: {}, console: ConsoleHelper());

//   // Check for 'help' or 'version' flag presence
//   if (helper.flags['help'] == true) {
//     responseHandler?.call(helper.getHelpResponse()) ?? print(helper.getHelpResponse());
//     return;
//   }

//   if (helper.flags['version'] == true) {
//     responseHandler?.call(helper.getVersionResponse()) ?? print(helper.getVersionResponse());
//     return;
//   }

//   // Proceed with command validation and callback processing
//   final callbackMap = await callbackMapper(helper);
//   //
// }
