String convertDartToYamlImpl(Map<String, dynamic> map, {int indentLevel = 0}) {
  final StringBuffer buffer = StringBuffer();
  final String indent = '  ' * indentLevel;

  map.forEach((key, value) {
    buffer.write(indent);
    buffer.write('$key: ');

    if (value is Map<String, dynamic>) {
      buffer.writeln(); // Move to the next line for nested maps
      buffer.write(convertDartToYamlImpl(value, indentLevel: indentLevel + 1));
    } else if (value is List) {
      buffer.writeln(); // Move to the next line for lists
      buffer.write(_convertListToYaml(value, indentLevel: indentLevel + 1));
    } else {
      buffer.writeln(value); // Primitive types: String, int, bool, etc.
    }
  });

  return buffer.toString();
}

String _convertListToYaml(List<dynamic> list, {int indentLevel = 0}) {
  final StringBuffer buffer = StringBuffer();
  final String indent = '  ' * indentLevel;

  for (var item in list) {
    buffer.write(indent);
    buffer.write('- ');

    if (item is Map<String, dynamic>) {
      buffer.writeln(); // Move to the next line for nested maps
      buffer.write(convertDartToYamlImpl(item, indentLevel: indentLevel + 1));
    } else if (item is List) {
      buffer.writeln(); // Move to the next line for nested lists
      buffer.write(_convertListToYaml(item, indentLevel: indentLevel + 1));
    } else {
      buffer.writeln(item); // Primitive types: String, int, bool, etc.
    }
  }

  return buffer.toString();
}
