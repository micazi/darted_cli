import 'package:darted_cli/yaml_module.dart';

class PackageLogic {
  static doSomething() {}
  // --> Starting 0.0.18, Using Yaml Validation!
  manipulateYaml() async {
    //1. Supply a validation Schema
    final yamlSchema = YamlValidationSchema(
      fields: {
        'some_key': FieldRule(type: 'string', required: true),
        'another_key': FieldRule(
          type: 'map',
          required: false,
          nestedFields: {
            'nested_1': FieldRule(type: 'string', required: true),
            'nested_2': FieldRule(type: 'string', required: false),
          },
        ),
        'some_options': FieldRule(
          type: 'map',
          required: false,
          nestedFields: {
            'enable_this': FieldRule(type: 'bool', required: false),
            'has_these': FieldRule(type: 'list', required: false),
          },
        ),
      },
    );
    //2. Load the yaml file.
    final yamlFilePath = 'path/to/yaml';
    final YamlMap yamlContent = await YamlModule.load(yamlFilePath);
    //2. Validate the Yaml content with the schema.
    try {
      await YamlModule.validate(yamlContent, yamlSchema);
      print('Validation successful! The configuration file is correct.');
    } catch (e) {
      print('Validation failed: $e');
    }
  }
}
