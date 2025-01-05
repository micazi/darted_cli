import 'package:yaml/yaml.dart';
// ignore: implementation_imports
import 'package:yaml/src/error_listener.dart';
import '../../../../io_helper.dart';

/// Load `YamlMap` model from the Yaml file path.
Future<YamlMap> loadYamlImpl(String path) async {
  return await loadYamlDocument(await IOHelper.file.readAsString(path),
          errorListener: _ErrListener())
      .contents
      .value;
}

class _ErrListener extends ErrorListener {
  @override
  void onError(YamlException error) {
    throw Exception('Error while parsing YAML file: $error');
  }
}
