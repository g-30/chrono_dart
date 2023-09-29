import '../../chrono.dart' show Parser, ParsingContext;
import '../../types.dart' show RegExpChronoMatch;

abstract class AbstractParserWithWordBoundaryChecking implements Parser {
  RegExp innerPattern(ParsingContext context);

  /// @returns ParsingComponents | ParsingResult | Map<Component, number> | null
  dynamic innerExtract(
    ParsingContext context,
    RegExpChronoMatch match,
  );

  RegExp? _cachedInnerPattern;
  RegExp? _cachedPattern;

  String patternLeftBoundary() {
    return "(\\W|^)";
  }

  @override
  RegExp pattern(ParsingContext context) {
    final innerPattern = this.innerPattern(context);
    if (innerPattern == _cachedInnerPattern) {
      return _cachedPattern!;
    }

    _cachedPattern = RegExp("${patternLeftBoundary()}${innerPattern.pattern}",
        caseSensitive: innerPattern.isCaseSensitive,
        multiLine: innerPattern.isMultiLine);
    _cachedInnerPattern = innerPattern;
    return _cachedPattern!;
  }

  @override
  extract(ParsingContext context, RegExpChronoMatch match) {
    final header = match[1] ?? "";
    match.index = match.index + header.length;
    match[0] = match[0]!.substring(header.length);
    for (var i = 2; i < match.groupCount; i++) {
      match[i - 1] = match[i];
    }

    return innerExtract(context, match);
  }
}
