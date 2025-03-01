// ignore_for_file: public_member_api_docs, sort_constructors_first
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
    this.canBeNegated = false,
    this.appliedByDefault = false,
  });

  static DartedFlag help = DartedFlag(
      name: 'help',
      abbreviation: 'h',
      description: 'show this helpful message.',
      canBeNegated: false,
      appliedByDefault: false);
  static DartedFlag version = DartedFlag(
      name: 'version',
      description: 'show the version of the tool.',
      abbreviation: 'v',
      canBeNegated: false,
      appliedByDefault: false);

  @override
  String toString() {
    return 'DartedFlag(name: $name, abbreviation: $abbreviation, description : $description , canBeNegated: $canBeNegated, appliedByDefault: $appliedByDefault)';
  }

  DartedFlag copyWith({
    String? name,
    String? abbreviation,
    String? description,
    bool? canBeNegated,
    bool? appliedByDefault,
  }) {
    return DartedFlag(
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      description: description ?? this.description,
      canBeNegated: canBeNegated ?? this.canBeNegated,
      appliedByDefault: appliedByDefault ?? this.appliedByDefault,
    );
  }
}
