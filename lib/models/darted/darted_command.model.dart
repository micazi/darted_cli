// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'darted_argument.model.dart';
import 'darted_flag.model.dart';

class DartedCommand {
  final String name;
  final Function(Map<String, dynamic?>? arguments, Map<String, bool>? flags) callback;
  final List<DartedCommand>? subCommands;
  //
  final List<DartedArgument?>? arguments;
  final List<DartedFlag>? flags;
  DartedCommand({
    required this.name,
    required this.callback,
    this.subCommands,
    this.arguments,
    this.flags,
  });

  @override
  String toString() {
    return 'DartedCommand(name: $name, callback: $callback, subCommands: $subCommands, arguments: $arguments, flags: $flags)';
  }
}
