import 'package:yaml/yaml.dart';

/// Extract all data from a YAML file as primitive data types (String, int, bool, List, Map).
Map<String, dynamic> extractDataImpl(YamlMap yamlContent) {
  try {
    // Convert YAML content to Dart native types.
    return _convertYamlToDart(yamlContent);
  } catch (e) {
    print('Error extracting YAML data: $e');
    return {};
  }
}

/// Recursively convert YamlMap and YamlList to Dart native types.
Map<String, dynamic> _convertYamlToDart(YamlMap yamlMap) {
  final Map<String, dynamic> result = {};

  yamlMap.forEach((key, value) {
    if (value is YamlMap) {
      result[key] = _convertYamlToDart(value);
    } else if (value is YamlList) {
      result[key] = _convertYamlListToDart(value);
    } else {
      result[key] = value; // Primitive types: String, int, bool, etc.
    }
  });

  return result;
}

/// Convert YamlList to Dart native List.
List<dynamic> _convertYamlListToDart(YamlList yamlList) {
  return yamlList.map((item) {
    if (item is YamlMap) {
      return _convertYamlToDart(item);
    } else if (item is YamlList) {
      return _convertYamlListToDart(item);
    } else {
      return item; // Primitive types: String, int, bool, etc.
    }
  }).toList();
}
