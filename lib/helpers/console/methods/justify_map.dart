List<String> justifyMapImpl(Map<String, String> map, {int gapSeparatorSize = 8, String preKey = '', String postValue = ''}) {
  // Find the longest key name for proper justification
  int maxKeyLength = map.keys.map((m) => m.length).reduce((a, b) => a > b ? a : b);

  // Print each command with justified helper messages
  List<String> ret = [];
  map.forEach((k, v) {
    ret.add('$preKey${k.padRight(maxKeyLength)}${List.generate(gapSeparatorSize, (_) => ' ').join()}$v$postValue');
  });
  return ret;
}
