import '../../../chrono.dart' show ParsingContext;
import '../../../types.dart' show RegExpChronoMatch;
import '../constants.dart'
    show parseTimeUnits, TIME_UNITS_NO_ABBR_PATTERN, TIME_UNITS_PATTERN;
import '../../../results.dart' show ParsingComponents;
import '../../../common/parsers/AbstractParserWithWordBoundary.dart';
import "../../../utils/timeunits.dart" show reverseTimeUnits;

final _pattern = RegExp(
    "($TIME_UNITS_PATTERN)\\s{0,5}(?:ago|before|earlier)(?=\\W|\$)",
    caseSensitive: false);
final _strictPattern = RegExp(
    "($TIME_UNITS_NO_ABBR_PATTERN)\\s{0,5}(?:ago|before|earlier)(?=\\W|\$)",
    caseSensitive: false);

class ENTimeUnitAgoFormatParser extends AbstractParserWithWordBoundaryChecking {
  final bool _strictMode;

  ENTimeUnitAgoFormatParser(bool strictMode)
      : _strictMode = strictMode,
        super();

  @override
  RegExp innerPattern(context) {
    return _strictMode ? _strictPattern : _pattern;
  }

  @override
  innerExtract(ParsingContext context, RegExpChronoMatch match) {
    final timeUnits = parseTimeUnits(match[1]!);
    final outputTimeUnits = reverseTimeUnits(timeUnits);

    return ParsingComponents.createRelativeFromReference(
        context.reference, outputTimeUnits);
  }
}
