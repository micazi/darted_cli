import 'package:darted_cli/yaml_module.dart';
import 'package:test/test.dart';

void main() {
  group('YAML Serialization & Special Characters Regression', () {
    test('serializes strings containing colons and special characters safely',
        () {
      final data = {
        'url': 'http://localhost:8080/api',
        'title': 'Feature: New Release #1',
        'empty': '',
        'boolean_string': 'true',
        'simple': 'normal_value',
        'number': 42,
        'nested': {
          'description': 'A key: with a colon',
          'items': ['first: item', 'simple_item'],
        },
      };

      final yamlString = YamlModule.convertDartToYaml(data);

      expect(yamlString, contains('url: "http://localhost:8080/api"'));
      expect(yamlString, contains('title: "Feature: New Release #1"'));
      expect(yamlString, contains("empty: ''"));
      expect(yamlString, contains('boolean_string: "true"'));

      // Verify that output parses back to valid YAML
      final parsed = loadYaml(yamlString);
      expect(parsed, isA<YamlMap>());
      expect(parsed['url'], equals('http://localhost:8080/api'));
      expect(parsed['title'], equals('Feature: New Release #1'));
      expect(parsed['number'], equals(42));
      expect(parsed['nested']['description'], equals('A key: with a colon'));
      expect(parsed['nested']['items'][0], equals('first: item'));
    });
  });
}
