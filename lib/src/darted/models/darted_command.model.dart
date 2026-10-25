// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'darted_argument.model.dart';
import 'darted_flag.model.dart';

class DartedCommand {
  final String name;
  final Function(Map<String, dynamic>? arguments, Map<String, bool>? flags)
      callback;
  final String? helperDescription;
  final List<DartedCommand>? subCommands;
  //
  final List<DartedArgument?>? arguments;
  final List<DartedFlag>? flags;
  final bool isConfigurableInFile;

  DartedCommand({
    required this.name,
    required this.callback,
    this.helperDescription,
    this.subCommands,
    this.arguments,
    this.flags,
    this.isConfigurableInFile = true,
  });

  DartedCommand copyWith({
    String? name,
    Function(Map<String, dynamic>? arguments, Map<String, bool>? flags)?
        callback,
    String? helperDescription,
    List<DartedCommand>? subCommands,
    List<DartedArgument?>? arguments,
    List<DartedFlag>? flags,
    bool? isConfigurableInFile,
  }) {
    return DartedCommand(
      name: name ?? this.name,
      callback: callback ?? this.callback,
      helperDescription: helperDescription ?? this.helperDescription,
      subCommands: subCommands ?? this.subCommands,
      arguments: arguments ?? this.arguments,
      flags: flags ?? this.flags,
      isConfigurableInFile: isConfigurableInFile ?? this.isConfigurableInFile,
    );
  }

  @override
  String toString() {
    return 'DartedCommand(name: $name, callback: $callback, helperDescription: $helperDescription, subCommands: $subCommands, arguments: $arguments, flags: $flags, isConfigurableInFile: $isConfigurableInFile)';
  }
}
