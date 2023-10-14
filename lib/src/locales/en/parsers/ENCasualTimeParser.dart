// ignore_for_file: library_prefixes
import '../../../results.dart' show ParsingComponents;
import '../../../chrono.dart' show ParsingContext;
import '../../../types.dart' show RegExpChronoMatch;
import '../../../common/parsers/AbstractParserWithWordBoundary.dart';
import '../../../common/casual_references.dart' as casualReferences;

final _pattern = RegExp(
    r'(?:this)?\s{0,3}(morning|afternoon|evening|night|midnight|midday|noon)(?=\W|$)',
    caseSensitive: false);

class ENCasualTimeParser extends AbstractParserWithWordBoundaryChecking {
  @override
  innerPattern(context) {
    return _pattern;
  }

  @override
  innerExtract(ParsingContext context, RegExpChronoMatch match) {
    ParsingComponents? component;
    switch (match[1]!.toLowerCase()) {
      case "afternoon":
        component = casualReferences.afternoon(context.reference);
        break;
      case "evening":
      case "night":
        component = casualReferences.evening(context.reference);
        break;
      case "midnight":
        component = casualReferences.midnight(context.reference);
        break;
      case "morning":
        component = casualReferences.morning(context.reference);
        break;
      case "noon":
      case "midday":
        component = casualReferences.noon(context.reference);
        break;
    }
    if (component != null) {
      component.addTag("parser/ENCasualTimeParser");
    }
    return component;
  }
}
