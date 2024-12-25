import 'package:yaml/yaml.dart';
import 'src/src.exports.dart';
//
export 'package:yaml/yaml.dart';
export 'src/src.exports.dart';

class YamlModule {
  /// Load a yaml file into Yaml Map with content that are either maps or lists.
  static Future<YamlMap> load(String path) async => await loadYamlImpl(path);

  /// Validate a yaml file content using a validation schema.
  static Future<void> validate(
          YamlMap yamlContent, YamlValidationSchema schema) async =>
      await validateYamlImpl(yamlContent, schema);
}
