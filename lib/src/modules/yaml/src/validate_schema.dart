import 'package:yaml/yaml.dart';
import '../../../../io_helper.dart';
import 'enums/enums.exports.dart';
import 'models/yaml_validation_schema.model.dart';
import 'package:path/path.dart' as p;

Future<void> validateYamlImpl(YamlMap yamlContent, YamlValidationSchema schema,
    {String? yamlFilePath}) async {
  final YamlMap config = yamlContent;

  schema.fields.forEach((fieldKey, rule) {
    _validateField(fieldKey, rule, config[fieldKey], yamlFilePath);
  });
}

void _validateField(
    String fieldKey, FieldRule rule, dynamic value, String? yamlFilePath) {
  // Validate required fields
  if (rule.required && value == null) {
    throw ('Missing required field: $fieldKey');
  }

  // Type validation
  if (value != null) {
    switch (rule.type) {
      case YamlValueType.string:
        if (value is! String) {
          throw ('Type Mismatch: $fieldKey must be a String, but got ${value.runtimeType}');
        }
        break;
      case YamlValueType.int:
        if (value is! int) {
          throw ('Type Mismatch: $fieldKey must be an Integer, but got ${value.runtimeType}');
        }
        break;
      case YamlValueType.bool:
        if (value is! bool) {
          throw ('Type Mismatch: $fieldKey must be a Boolean, but got ${value.runtimeType}');
        }
        break;
      case YamlValueType.list:
        if (value is! List) {
          throw ('Type Mismatch: $fieldKey must be a List, but got ${value.runtimeType}');
        }
        if (rule.allowedValues != null &&
            !value.every((e) => rule.allowedValues!.contains(e))) {
          throw ('Invalid Value: $fieldKey contains disallowed values. Allowed: [${rule.allowedValues!.join(', ')}]');
        }
        break;
      case YamlValueType.map:
        if (value is! Map) {
          throw ('Type Mismatch: $fieldKey must be a Map, but got ${value.runtimeType}');
        }
        if (rule.nestedFields != null) {
          rule.nestedFields!.forEach((nestedKey, nestedRule) {
            _validateField('$fieldKey.$nestedKey', nestedRule, value[nestedKey],
                yamlFilePath);
          });
        }
        break;
      case YamlValueType.directoryPath:
        _validateDirectoryOrFilePath(
            fieldKey: fieldKey,
            path: value,
            type: YamlValueType.directoryPath,
            yamlFilePath: yamlFilePath);
        break;
      case YamlValueType.filePath:
        _validateDirectoryOrFilePath(
            fieldKey: fieldKey,
            path: value,
            type: YamlValueType.filePath,
            yamlFilePath: yamlFilePath);
        break;
    }
  }

  // matchesPattern validation
  if (rule.matchesPattern != null &&
      value is String &&
      !rule.matchesPattern!.hasMatch(value)) {
    throw ('Invalid Value: $fieldKey should match the pattern "${rule.matchesPattern!.pattern}", but got "$value"');
  }

  // Ensure nestedFields is only used with Map type
  if (rule.nestedFields != null && rule.type != YamlValueType.map) {
    throw ('Invalid Schema: $fieldKey cannot have nested fields unless it is a Map type');
  }
}

/// Validate if a directory/file path exists (either relative or absolute).
Future<void> _validateDirectoryOrFilePath({
  required String fieldKey,
  required String path,
  required YamlValueType type,
  String? yamlFilePath,
}) async {
  // Determine if the path is absolute
  final bool isAbsolutePath = p.isAbsolute(path);

  // If the path starts with "abs", strip the prefix and treat it as absolute
  if (path.startsWith('abs')) {
    path = path.replaceFirst('abs', '').trim();

    // If the path is still not absolute after removing 'abs', throw an error
    if (!p.isAbsolute(path)) {
      throw ('Invalid Value: $fieldKey must be an absolute path when using the "abs" prefix.');
    }
  } else {
    // If the path is absolute but doesn't start with "abs", throw an error
    if (isAbsolutePath) {
      throw ('Invalid Value: $fieldKey contains an absolute path but is missing the "abs" prefix.');
    }

    // Resolve relative paths using the YAML file path
    if (yamlFilePath == null) {
      throw ('Invalid Value: $fieldKey has a relative path, but no yamlFilePath was provided to resolve it.');
    }

    path = p.normalize(p.join(p.dirname(yamlFilePath), path));
  }

  // Check if the path exists and matches the expected type
  if (type == YamlValueType.directoryPath) {
    if (!Directory(path).existsSync()) {
      throw ('Invalid Value: $fieldKey directory path "$path" does not exist.');
    }
  } else if (type == YamlValueType.filePath) {
    if (!File(path).existsSync()) {
      throw ('Invalid Value: $fieldKey file path "$path" does not exist.');
    }
  }
}
