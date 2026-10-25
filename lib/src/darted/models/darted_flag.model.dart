// ignore_for_file: public_member_api_docs, sort_constructors_first
class DartedFlag {
  final String name;
  final String abbreviation;
  final String? description;
  //
  final bool canBeNegated;
  final bool appliedByDefault;
  final bool isConfigurableInFile;
  final String? environmentVariable;

  DartedFlag({
    required this.name,
    required this.abbreviation,
    this.description,
    this.canBeNegated = false,
    this.appliedByDefault = false,
    this.isConfigurableInFile = true,
    this.environmentVariable,
  });

  static DartedFlag help = DartedFlag(
    name: 'help',
    abbreviation: 'h',
    description: 'show this helpful message.',
    canBeNegated: false,
    appliedByDefault: false,
    isConfigurableInFile: false,
  );
  static DartedFlag version = DartedFlag(
    name: 'version',
    description: 'show the version of the tool.',
    abbreviation: 'v',
    canBeNegated: false,
    appliedByDefault: false,
    isConfigurableInFile: false,
  );

  @override
  String toString() {
    return 'DartedFlag(name: $name, abbreviation: $abbreviation, description: $description, canBeNegated: $canBeNegated, appliedByDefault: $appliedByDefault, isConfigurableInFile: $isConfigurableInFile, environmentVariable: $environmentVariable)';
  }

  DartedFlag copyWith({
    String? name,
    String? abbreviation,
    String? description,
    bool? canBeNegated,
    bool? appliedByDefault,
    bool? isConfigurableInFile,
    String? environmentVariable,
  }) {
    return DartedFlag(
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      description: description ?? this.description,
      canBeNegated: canBeNegated ?? this.canBeNegated,
      appliedByDefault: appliedByDefault ?? this.appliedByDefault,
      isConfigurableInFile: isConfigurableInFile ?? this.isConfigurableInFile,
      environmentVariable: environmentVariable ?? this.environmentVariable,
    );
  }
}
