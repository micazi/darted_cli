import 'package:yaml/yaml.dart';
import '../../io/helper/io.helper.dart';
//
export 'package:yaml/yaml.dart';

class YamlModule {
  /// Load a yaml file into Yaml Map with content that are either maps or lists.
  static Future<YamlMap> load(String path) async {
    return loadYamlDocument(await IOHelper.file.readAsString(path))
        .contents
        .value;
  }
}
