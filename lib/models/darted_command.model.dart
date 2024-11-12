import 'darted_argument.model.dart';
import 'darted_flag.model.dart';

class DartedCommand {
  final String name;
  final List<DartedCommand>? subCommands;
  //
  final List<DartedArgument?>? arguments;
  final List<DartedFlag>? flags;
  DartedCommand({
    required this.name,
    this.subCommands,
    this.arguments,
    this.flags,
  });

  @override
  String toString() {
    return 'DartedCommand(name: $name, subCommands: $subCommands, arguments: $arguments, flags: $flags)';
  }
}
