String repeatedTimeunitPattern(String prefix, String singleTimeunitPattern) {
  final singleTimeunitPatternNoCapture =
      singleTimeunitPattern.replaceAll(RegExp(r'\((?!\?)'), "(?:");
  return "$prefix$singleTimeunitPatternNoCapture\\s{0,5}(?:,?\\s{0,5}$singleTimeunitPatternNoCapture){0,10}";
}

List<String> extractTerms(dynamic dictionary) {
  assert(dictionary is Iterable || dictionary is Map);

  List<String> keys = [];
  if (dictionary is Iterable) {
    keys = [...dictionary];
  } else {
    keys = Map.from(dictionary).keys.map((a) => a.toString()).toList();
  }

  return keys;
}

String matchAnyPattern(dynamic dictionary) {
  // TODO: More efficient regex pattern by considering duplicated prefix

  final terms = extractTerms(dictionary);
  terms.sort((a, b) => b.length - a.length);
  final joinedTerms = terms.join("|").replaceAll(RegExp(r'\.'), "\\.");

  return "(?:$joinedTerms)";
}
