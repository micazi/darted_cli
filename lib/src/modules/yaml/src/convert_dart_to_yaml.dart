String convertDartToYamlImpl(Map<dynamic, dynamic> map, {int indentLevel = 0}) {
  final StringBuffer buffer = StringBuffer();
  final String indent = '  ' * indentLevel;

  map.forEach((key, value) {
    buffer.write(indent);
    buffer.write('$key: ');

    if (value is Map) {
      buffer.writeln();
      buffer.write(convertDartToYamlImpl(value, indentLevel: indentLevel + 1));
    } else if (value is List) {
      buffer.writeln();
      buffer.write(_convertListToYaml(value, indentLevel: indentLevel + 1));
    } else {
      buffer.writeln(_formatYamlScalar(value));
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

    if (item is Map) {
      buffer.writeln();
      buffer.write(convertDartToYamlImpl(item, indentLevel: indentLevel + 1));
    } else if (item is List) {
      buffer.writeln();
      buffer.write(_convertListToYaml(item, indentLevel: indentLevel + 1));
    } else {
      buffer.writeln(_formatYamlScalar(item));
    }
  }

  return buffer.toString();
}

String _formatYamlScalar(dynamic value) {
  if (value is String) {
    if (value.isEmpty) return "''";
    final needsQuotes = value.contains(':') ||
        value.contains('#') ||
        value.contains('\n') ||
        value.contains('"') ||
        value.contains("'") ||
        value.startsWith(' ') ||
        value.endsWith(' ') ||
        value == 'true' ||
        value == 'false' ||
        value == 'null';
    if (needsQuotes) {
      final escaped = value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
      return '"$escaped"';
    }
    return value;
  }
  return value?.toString() ?? 'null';
}
