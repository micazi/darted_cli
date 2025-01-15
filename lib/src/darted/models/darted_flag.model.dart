class DartedFlag {
  final String name;
  final String abbreviation;
  final String? description;
  //
  final bool canBeNegated;
  final bool appliedByDefault;
  DartedFlag({
    required this.name,
    required this.abbreviation,
    this.description,
    required this.canBeNegated,
    required this.appliedByDefault,
  });

  static DartedFlag help = DartedFlag(name: 'help', abbreviation: 'h', description: 'show this helpful message.', canBeNegated: false, appliedByDefault: false);
  static DartedFlag version = DartedFlag(name: 'version', description: 'show the version of the tool.', abbreviation: 'v', canBeNegated: false, appliedByDefault: false);

  @override
  String toString() {
    return 'DartedFlag(name: $name, abbreviation: $abbreviation, description : $description , canBeNegated: $canBeNegated, appliedByDefault: $appliedByDefault)';
  }
}
