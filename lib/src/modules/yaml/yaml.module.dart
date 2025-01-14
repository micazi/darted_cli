import 'package:yaml/yaml.dart' show YamlMap;
import 'src/src.exports.dart';
//
export 'package:yaml/yaml.dart';
export 'src/src.exports.dart';

class YamlModule {
  /// Load a yaml file into Yaml Map with content that are either maps or lists.
  static Future<YamlMap> load(String path) async => await loadYamlImpl(path);

  /// Validate a yaml file content using a validation schema. (Optionally pass in `yamlFilePath` to validate relative pathes)
  static Future<void> validate(YamlMap yamlContent, YamlValidationSchema schema,
          {String? yamlFilePath}) async =>
      await validateYamlImpl(yamlContent, schema, yamlFilePath: yamlFilePath);

  /// Extract yaml content to a dart-native Map\<String,dynamic\>
  static Map<String, dynamic> extractData(YamlMap yamlContent) =>
      extractDataImpl(yamlContent);

  /// Convert a Map\<String,dynamic\> into an indented, correct, Yaml String.
  static String convertDartToYaml(Map<String, dynamic> map) =>
      convertDartToYamlImpl(map);
}
