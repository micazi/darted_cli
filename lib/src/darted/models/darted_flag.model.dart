class DartedFlag {
  final String name;
  final String abbreviation;
  final String? describtion;
  //
  final bool canBeNegated;
  final bool appliedByDefault;
  DartedFlag({
    required this.name,
    required this.abbreviation,
    this.describtion,
    required this.canBeNegated,
    required this.appliedByDefault,
  });

  static DartedFlag help = DartedFlag(
      name: 'help',
      abbreviation: 'h',
      describtion: 'show this helpful message.',
      canBeNegated: false,
      appliedByDefault: false);
  static DartedFlag version = DartedFlag(
      name: 'version',
      describtion: 'show the version of the tool.',
      abbreviation: 'v',
      canBeNegated: false,
      appliedByDefault: false);

  @override
  String toString() {
    return 'DartedFlag(name: $name, abbreviation: $abbreviation, describtion: $describtion, canBeNegated: $canBeNegated, appliedByDefault: $appliedByDefault)';
  }
}
