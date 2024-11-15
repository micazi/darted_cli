import 'package:darted_cli/darted_cli.dart';

/// Validates that all required arguments for a command exist and are valid.
Map<String, dynamic>? validatedTheArguments(DartedCommand command, Map<String, dynamic> inputArguments) {
  ConsoleHelper.write('The arguments in the command: ${command.arguments}', newLine: true);
  ConsoleHelper.write('The arguments entered: $inputArguments', newLine: true);
  //
  Map<String, dynamic> validatedArgs = {};
  for (final DartedArgument? argument in (command.arguments ?? [])) {
    if (argument != null) {
      final String acceptedargName = argument.name;
      final String acceptedargAbbreviation = argument.abbreviation;
      final bool isMultiOption = argument.isMultiOption;
      final String? acceptedOptions = argument.acceptedMultiOptionValues;
      //
      if (inputArguments.keys.contains(acceptedargName)) {
        if (isMultiOption && acceptedOptions != null) {
          // make sure the value is in the accepted options
          List<String> inputedOptions = inputArguments[acceptedargName].toString().split(argument.optionsSeparator ?? '/');
          //
          if (acceptedOptions.split(argument.optionsSeparator ?? '/').containsAll(inputedOptions)) {
            validatedArgs.addEntries([MapEntry(acceptedargName, inputArguments[acceptedargName])]);
          }
        } else {
          validatedArgs.addEntries([MapEntry(acceptedargName, inputArguments[acceptedargName])]);
        }
      }
      if (inputArguments.keys.contains(acceptedargAbbreviation)) {
        if (isMultiOption && acceptedOptions != null) {
          // make sure the value is in the accepted options
          List<String> inputedOptions = inputArguments[acceptedargAbbreviation].toString().split(argument.optionsSeparator ?? '/');
          //
          if (acceptedOptions.split(argument.optionsSeparator ?? '/').containsAll(inputedOptions)) {
            validatedArgs.addEntries([MapEntry(acceptedargAbbreviation, inputArguments[acceptedargAbbreviation])]);
          }
        } else {
          validatedArgs.addEntries([MapEntry(acceptedargAbbreviation, inputArguments[acceptedargAbbreviation])]);
        }
      }
    }
    // if (inputArguments.containsKey(acceptedargName)) {
    //   final argValue = inputArguments[acceptedargName];
    //   if (argument.isMultiOption && argument.acceptedMultiOptionValues != null) {
    //     final acceptedValues = argument.acceptedMultiOptionValues!.split(argument.optionsSeparator ?? '/');
    //     final userValues = argValue.split(argument.optionsSeparator ?? '/');
    //     if (!userValues.every((val) => acceptedValues.contains(val))) {
    //       print("Error: Argument '$acceptedargName' contains invalid values.");
    //       return false;
    //     }
    //   }
    // }
  }
  return validatedArgs;
}

extension ListExtension<E> on List<E> {
  bool containsAll(List<E> otherList) {
    List<bool> checks = [];
    //
    for (E thisElement in this) {
      checks.add(otherList.contains(thisElement));
    }
    return !checks.contains(false);
  }
}
