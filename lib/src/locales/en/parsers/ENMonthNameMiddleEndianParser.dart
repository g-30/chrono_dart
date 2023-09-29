// ignore_for_file: prefer_interpolation_to_compose_strings, constant_identifier_names, slash_for_doc_comments
import '../../../chrono.dart' show ParsingContext;
import '../../../types.dart' show RegExpChronoMatch, Component;
import '../../../calculation/years.dart' show findYearClosestToRef;
import '../constants.dart'
    show
        MONTH_DICTIONARY,
        YEAR_PATTERN,
        parseYear,
        ORDINAL_NUMBER_PATTERN,
        parseOrdinalNumberPattern;
import '../../../utils/pattern.dart' show matchAnyPattern;
import '../../../common/parsers/AbstractParserWithWordBoundary.dart';

final _pattern = RegExp(
    "(${matchAnyPattern(MONTH_DICTIONARY)})" +
        "(?:-|/|\\s*,?\\s*)" +
        "($ORDINAL_NUMBER_PATTERN)(?!\\s*(?:am|pm))\\s*" +
        "(?:" +
        "(?:to|\\-)\\s*" +
        "($ORDINAL_NUMBER_PATTERN)\\s*" +
        ")?" +
        "(?:" +
        "(?:-|/|\\s*,?\\s*)" +
        "($YEAR_PATTERN)" +
        ")?" +
        "(?=\\W|\$)(?!\\:\\d)",
    caseSensitive: false);

const MONTH_NAME_GROUP = 1;
const DATE_GROUP = 2;
const DATE_TO_GROUP = 3;
const YEAR_GROUP = 4;

/**
 * The parser for parsing US's date format that begin with month's name.
 *  - January 13
 *  - January 13, 2012
 *  - January 13 - 15, 2012
 * Note: Watch out for:
 *  - January 12:00
 *  - January 12.44
 *  - January 1222344
 */
class ENMonthNameMiddleEndianParser
    extends AbstractParserWithWordBoundaryChecking {
  @override
  RegExp innerPattern(context) {
    return _pattern;
  }

  @override
  innerExtract(ParsingContext context, RegExpChronoMatch match) {
    final month = MONTH_DICTIONARY[match[MONTH_NAME_GROUP]!.toLowerCase()]!;
    final day = parseOrdinalNumberPattern(match[DATE_GROUP]!)!;
    if (day > 31) {
      return null;
    }

    final components = context.createParsingComponents({
      day: day,
      month: month,
    });

    if (match[YEAR_GROUP] != null) {
      final year = parseYear(match[YEAR_GROUP]!)!;
      components.assign(Component.year, year);
    } else {
      final year = findYearClosestToRef(context.reference.instant, day, month);
      components.imply(Component.year, year);
    }

    if (match[DATE_TO_GROUP] == null) {
      return components;
    }

    // Text can be 'range' value. Such as 'January 12 - 13, 2012'
    final endDate = parseOrdinalNumberPattern(match[DATE_TO_GROUP]!)!;
    final result = context.createParsingResult(match.index, match[0]);
    result.start = components;
    result.end = components.clone();
    result.end!.assign(Component.day, endDate);

    return result;
  }
}
