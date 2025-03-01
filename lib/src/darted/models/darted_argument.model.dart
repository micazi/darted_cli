class DartedArgument {
  final String name;
  final String abbreviation;
  final String? description;
  //
  final String? defaultValue;
  final bool isMainReq;
  //
  final bool isMultiOption;
  final String? acceptedMultiOptionValues;
  final String? optionsSeparator;
  DartedArgument({
    required this.name,
    required this.abbreviation,
    this.description,
    this.defaultValue,
    this.isMainReq = false,
    this.isMultiOption = false,
    this.acceptedMultiOptionValues,
    this.optionsSeparator,
  });

  @override
  String toString() {
    return 'DartedArgument(name: $name, abbreviation: $abbreviation, description: $description, defaultValue: $defaultValue, isMainReq: $isMainReq, isMultiOption: $isMultiOption, acceptedMultiOptionValues: $acceptedMultiOptionValues, optionsSeparator: $optionsSeparator)';
  }

  DartedArgument copyWith({
    String? name,
    String? abbreviation,
    String? description,
    String? defaultValue,
    bool? isMainReq,
    bool? isMultiOption,
    String? acceptedMultiOptionValues,
    String? optionsSeparator,
  }) {
    return DartedArgument(
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      description: description ?? this.description,
      defaultValue: defaultValue ?? this.defaultValue,
      isMainReq: isMainReq ?? this.isMainReq,
      isMultiOption: isMultiOption ?? this.isMultiOption,
      acceptedMultiOptionValues:
          acceptedMultiOptionValues ?? this.acceptedMultiOptionValues,
      optionsSeparator: optionsSeparator ?? this.optionsSeparator,
    );
  }
}
