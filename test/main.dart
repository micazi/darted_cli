import 'package:darted_cli/io_helper.dart';
import 'package:darted_cli/yaml_module.dart';

void main() async {
  File file = File('./test/passing.yaml');
  final yamlContent = await YamlModule.load(
    file.path,
  );

  final schema = YamlValidationSchema(
    fields: {
      'stringField': FieldRule(
          type: YamlValueType.string,
          required: true,
          matchesPattern: RegExp(r'[a-z]@[0-9]')),
      'intField': FieldRule(type: YamlValueType.int, required: true),
      'boolField': FieldRule(type: YamlValueType.bool, required: true),
      'listField': FieldRule(
        type: YamlValueType.list,
        required: true,
        allowedValues: ['value1', 'value2', 'value3'],
      ),
      'mapField': FieldRule(
        type: YamlValueType.map,
        required: true,
        nestedFields: {
          'nestedString': FieldRule(type: YamlValueType.string, required: true),
          'nestedInt': FieldRule(type: YamlValueType.int, required: true),
        },
      ),
      'directoryPathField':
          FieldRule(type: YamlValueType.directoryPath, required: true),
      'filePathField': FieldRule(type: YamlValueType.filePath, required: true),
      'absoluteDirectoryPathField':
          FieldRule(type: YamlValueType.directoryPath, required: true),
      'absoluteFilePathField':
          FieldRule(type: YamlValueType.filePath, required: true),
    },
  );

  await YamlModule.validate(yamlContent, schema,
      yamlFilePath: './test/passing.yaml');
}
