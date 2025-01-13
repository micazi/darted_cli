import 'package:yaml/yaml.dart';
import '../../../../io_helper.dart';
import 'enums/enums.exports.dart';
import 'exceptions/exceptions.exports.dart';
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
        if (rule.recursiveMapSchema != null) {
          _validateRecursiveMap(
              fieldKey, value, rule.recursiveMapSchema!, yamlFilePath);
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
}

void _validateRecursiveMap(String fieldKey, Map<dynamic, dynamic> map,
    Map<RegExp, FieldRule?> recursiveMapSchema, String? yamlFilePath) {
  map.forEach((key, value) {
    final String keyStr = key.toString();
    bool matched = false;

    for (final pattern in recursiveMapSchema.keys) {
      if (pattern.hasMatch(keyStr)) {
        matched = true;
        final FieldRule? rule = recursiveMapSchema[pattern];
        if (rule != null) {
          _validateField(
              '$fieldKey.$keyStr',
              rule.copyWith(
                  recursiveMapSchema: value is Map ? recursiveMapSchema : null),
              value,
              yamlFilePath);
        }
        break;
      }
    }

    if (!matched) {
      throw ('No matching pattern found for key "$keyStr" in $fieldKey');
    }
  });
}

/// Validate if a directory/file path exists (either relative or absolute).
Future<void> _validateDirectoryOrFilePath({
  required String fieldKey,
  required String path,
  required YamlValueType type,
  String? yamlFilePath,
}) async {
  if (path.startsWith('abs:')) {
    path = path.replaceFirst('abs:', '').trim();
    if (!p.isAbsolute(path)) {
      throw InvalidValueException(
          fieldKey, 'must be an absolute path when using the "abs:" prefix.');
    }
  } else if (p.isAbsolute(path)) {
    throw InvalidValueException(fieldKey,
        'contains an absolute path but is missing the "abs:" prefix.');
  } else if (yamlFilePath == null) {
    throw InvalidValueException(fieldKey,
        'has a relative path, but no yamlFilePath was provided to resolve it.');
  } else {
    path = p.normalize(p.join(p.dirname(yamlFilePath), path));
  }

  if (type == YamlValueType.directoryPath && !Directory(path).existsSync()) {
    throw InvalidValueException(
        fieldKey, 'directory path "$path" does not exist.');
  } else if (type == YamlValueType.filePath && !File(path).existsSync()) {
    throw InvalidValueException(fieldKey, 'file path "$path" does not exist.');
  }
}
