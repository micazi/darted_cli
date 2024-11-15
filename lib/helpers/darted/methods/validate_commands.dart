import '../../../models/models.exports.dart';

DartedCommand? validateCommandHierarchy(List<DartedCommand> cT, List<String> commandStack) {
  print("validating the stack: $commandStack\n");
  DartedCommand? currentCommand;
  List<DartedCommand> availableCommands = cT;

  for (final commandName in commandStack) {
    currentCommand = availableCommands
        .where(
          (cmd) => cmd.name == commandName,
        )
        .firstOrNull;

    if (currentCommand == null) {
      // Command not found in the current level of hierarchy
      return null;
    }

    // Check if there are no more commands in the stack and we're at the end
    if (commandName == commandStack.last) {
      return currentCommand;
    }

    // Move to subcommands for the next iteration
    availableCommands = currentCommand.subCommands ?? [];

    // If no more subcommands are available but we still have commands in stack, show an error
    if (availableCommands.isEmpty && commandName != commandStack.last) {
      return null;
    }
  }

  return currentCommand;
}
