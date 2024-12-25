import 'package:yaml/yaml.dart';
import 'models/yaml_validation_schema.model.dart';

Future<void> validateYamlImpl(
    YamlMap yamlContent, YamlValidationSchema schema) async {
  // Parse the yaml map from the content.
  final YamlMap config = yamlContent;

  // Loop through the map keys to validate.
  schema.fields.forEach((fieldKey, rule) {
    validateField(fieldKey, rule, config[fieldKey]);
  });

  // If there were no exceptions, We are valid.
}

/// Validate the schema field with the supplied rule.
void validateField(String fieldKey, FieldRule rule, dynamic value) {
  if (rule.required && value == null) {
    throw ("Missing required field: $fieldKey");
  }

  if (value != null) {
    switch (rule.type) {
      case 'string':
        if (value is! String) {
          throw ('Type Mismatch: $fieldKey Must be String');
        }
        break;
      case 'int':
        if (value is! int) {
          throw ('Type Mismatch: $fieldKey Must be Integer');
        }
        break;
      case 'bool':
        if (value is! bool) {
          throw ('Type Mismatch: $fieldKey Must be Boolean');
        }
        break;
      case 'list':
        if (value is! List) {
          throw ('Type Mismatch: $fieldKey Must be a List');
        }
        break;
      case 'map':
        if (value is! Map) {
          throw ('Type Mismatch: $fieldKey Must be a Map');
        }
        if (rule.nestedFields != null) {
          rule.nestedFields!.forEach((nestedKey, nestedRule) {
            validateField('$fieldKey.$nestedKey', nestedRule, value[nestedKey]);
          });
        }
        break;
      default:
        throw ('Unknown type "${rule.type}" for key: $fieldKey');
    }
  }
}
