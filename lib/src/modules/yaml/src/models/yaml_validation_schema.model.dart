import '../enums/enums.exports.dart';

/// A class representing the validation schema for a YAML file.
class YamlValidationSchema {
  final Map<String, FieldRule> fields;

  YamlValidationSchema({required this.fields});
}

/// A class defining rules for a field in the YAML schema.
class FieldRule {
  final YamlValueType
      type; // Type of the field: 'string', 'int', 'bool', 'list', or 'map'.
  final bool required; // Whether the field is required.
  final List<String>? allowedValues; // List of allowed values for a 'list' key.
  final RegExp?
      matchesPattern; // A RegExp that this key needs to match to be valid (Only for String values).
  final Map<String, FieldRule>?
      nestedFields; // Nested fields if the type is 'map'.

  FieldRule({
    required this.type,
    this.required = false,
    this.allowedValues,
    this.matchesPattern,
    this.nestedFields,
  });
}
