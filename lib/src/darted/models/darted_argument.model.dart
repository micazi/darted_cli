class DartedArgument {
  final String name;
  final String abbreviation;
  final String? describtion;
  //
  final String? defaultValue;
  //
  final bool isMultiOption;
  final String? acceptedMultiOptionValues;
  final String? optionsSeparator;
  DartedArgument({
    required this.name,
    required this.abbreviation,
    this.describtion,
    this.defaultValue,
    required this.isMultiOption,
    this.acceptedMultiOptionValues,
    this.optionsSeparator,
  });

  @override
  String toString() {
    return 'DartedArgument(name: $name, abbreviation: $describtion,abbreviation: $describtion, defaultValue: $defaultValue, isMultiOption: $isMultiOption, acceptedMultiOptionValues: $acceptedMultiOptionValues, optionsSeparator: $optionsSeparator)';
  }
}
