import '../../../chrono.dart' show ParsingContext;
import '../../../results.dart' show ParsingComponents;
import '../../../types.dart' show Component, RegExpChronoMatch;
import '../../../common/parsers/AbstractParserWithWordBoundary.dart';

final _PATTERN = RegExp(r'([0-9]|0[1-9]|1[012])/([0-9]{4})');

const _MONTH_GROUP = 1;
const _YEAR_GROUP = 2;

/// Month/Year date format with slash "/" (also "-" and ".") between numbers
/// - 11/05
/// - 06/2005
class ENSlashMonthFormatParser extends AbstractParserWithWordBoundaryChecking {
  @override
  RegExp innerPattern(context) {
    return _PATTERN;
  }

  @override
  ParsingComponents innerExtract(ParsingContext context, RegExpChronoMatch match) {
    final year = int.tryParse(match[_YEAR_GROUP]!)!;
    final month = int.tryParse(match[_MONTH_GROUP]!)!;

    return context
        .createParsingComponents()
        .imply(Component.day, 1)
        .assign(Component.month, month)
        .assign(Component.year, year);
  }
}
