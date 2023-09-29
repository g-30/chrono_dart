// ignore_for_file: constant_identifier_names
import '../../../chrono.dart' show ParsingContext;
import '../../../types.dart' show RegExpChronoMatch;
import '../constants.dart'
    show parseTimeUnits, TIME_UNITS_NO_ABBR_PATTERN, TIME_UNITS_PATTERN;
import '../../../results.dart' show ParsingComponents;
import '../../../common/parsers/AbstractParserWithWordBoundary.dart';

final _pattern = RegExp(
  "($TIME_UNITS_PATTERN)\\s{0,5}(?:later|after|from now|henceforth|forward|out)(?=(?:\\W|\$))",
  caseSensitive: false,
);

final _strictPattern = RegExp(
  "($TIME_UNITS_NO_ABBR_PATTERN)(later|from now)(?=(?:\\W|\$))",
  caseSensitive: false,
);
const GROUP_NUM_TIMEUNITS = 1;

class ENTimeUnitLaterFormatParser
    extends AbstractParserWithWordBoundaryChecking {
  final bool _strictMode;

  ENTimeUnitLaterFormatParser(bool strictMode)
      : _strictMode = strictMode,
        super();

  @override
  RegExp innerPattern(context) {
    return _strictMode ? _strictPattern : _pattern;
  }

  @override
  innerExtract(ParsingContext context, RegExpChronoMatch match) {
    final fragments = parseTimeUnits(match[GROUP_NUM_TIMEUNITS]!);
    return ParsingComponents.createRelativeFromReference(
        context.reference, fragments);
  }
}
