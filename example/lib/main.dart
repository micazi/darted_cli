import 'package:darted_cli/yaml_module.dart';

class PackageLogic {
  static doSomething() {}
  // --> Starting 0.1.18, Using Yaml Validation!
  manipulateYaml() async {
    //1. Supply a validation Schema
    final yamlSchema = YamlValidationSchema(
      fields: {
        // --> Starting 0.1.21, Make sure to use YamlValueType enum instead of e.g 'string'.
        'some_key': FieldRule(type: YamlValueType.string, required: true),
        'another_key': FieldRule(
          type: YamlValueType.map,
          required: false,
          nestedFields: {
            'nested_1': FieldRule(type: YamlValueType.string, required: true),
            'nested_2': FieldRule(type: YamlValueType.string, required: false),
          },
        ),
        'some_options': FieldRule(
          type: YamlValueType.map,
          required: false,
          nestedFields: {
            'enable_this': FieldRule(type: YamlValueType.bool, required: false),
            'has_these': FieldRule(type: YamlValueType.list, required: false),
          },
        ),
        // --> Starting 0.1.21, You can add in file/directory path values and validate them!.
        'directoryPathField':
            FieldRule(type: YamlValueType.directoryPath, required: true),
        'filePathField':
            FieldRule(type: YamlValueType.filePath, required: true),
      },
    );
    //2. Load the yaml file.
    final yamlFilePath = 'path/to/yaml';
    final YamlMap yamlContent = await YamlModule.load(yamlFilePath);
    //2. Validate the Yaml content with the schema.
    try {
      // --> Starting 0.1.21, To validate file/directory pathes relative to your yaml file, supply the YAML file path, or use `abs:` before absolute pathes.
      await YamlModule.validate(yamlContent, yamlSchema,
          yamlFilePath: yamlFilePath);
      print('Validation successful! The configuration file is correct.');
    } catch (e) {
      print('Validation failed: $e');
    }
    // --> Starting 0.1.19, Extract your Yaml data!
    Map<String, dynamic> yamldata = YamlModule.extractData(yamlContent);
    print('Extracted data: $yamldata');
  }
}
