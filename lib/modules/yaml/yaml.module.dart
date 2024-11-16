import 'package:yaml/yaml.dart';
import '../../helpers/io/io.helper.dart';
//
export 'package:yaml/yaml.dart';

class YamlModule {
  //
  static Future<YamlMap> load(String path) async {
    return loadYamlDocument(await IOHelper.file.readAsString(path)).contents.value;
  }
}
