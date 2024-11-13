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

  factory DartedFlag.help() => DartedFlag(name: 'help', abbreviation: 'h', canBeNegated: false, appliedByDefault: false);
  factory DartedFlag.version() => DartedFlag(name: 'version', abbreviation: 'v', canBeNegated: false, appliedByDefault: false);

  @override
  String toString() {
    return 'DartedFlag(name: $name, abbreviation: $abbreviation, canBeNegated: $canBeNegated, appliedByDefault: $appliedByDefault)';
  }
}
