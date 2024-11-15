class DartedFlag {
  final String name;
  final String abbreviation;
  //
  final bool canBeNegated;
  final bool appliedByDefault;
  DartedFlag({
    required this.name,
    required this.abbreviation,
    required this.canBeNegated,
    required this.appliedByDefault,
  });

  static DartedFlag help = DartedFlag(name: 'help', abbreviation: 'h', canBeNegated: false, appliedByDefault: false);
  static DartedFlag version = DartedFlag(name: 'version', abbreviation: 'v', canBeNegated: false, appliedByDefault: false);

  @override
  String toString() {
    return 'DartedFlag(name: $name, abbreviation: $abbreviation, canBeNegated: $canBeNegated, appliedByDefault: $appliedByDefault)';
  }
}
