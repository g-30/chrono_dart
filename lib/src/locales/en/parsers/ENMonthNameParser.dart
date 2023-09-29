// ignore_for_file: prefer_interpolation_to_compose_strings, constant_identifier_names, slash_for_doc_comments
import '../../../chrono.dart' show ParsingContext;
import '../../../types.dart' show RegExpChronoMatch, Component;
import '../../../calculation/years.dart' show findYearClosestToRef;
import '../constants.dart'
    show MONTH_DICTIONARY, YEAR_PATTERN, parseYear, FULL_MONTH_NAME_DICTIONARY;
import '../../../utils/pattern.dart' show matchAnyPattern;
import '../../../common/parsers/AbstractParserWithWordBoundary.dart';

final _pattern = RegExp(
    // ignore: prefer_adjacent_string_concatenation
    "((?:in)\\s*)?" +
        "(${matchAnyPattern(MONTH_DICTIONARY)})" +
        "\\s*" +
        "(?:" +
        "[,-]?\\s*($YEAR_PATTERN)?" +
        ")?" +
        "(?=[^\\s\\w]|\\s+[^0-9]|\\s+\$|\$)",
    caseSensitive: false);

const _PREFIX_GROUP = 1;
const _MONTH_NAME_GROUP = 2;
const _YEAR_GROUP = 3;

/**
 * The parser for parsing month name and year.
 * - January, 2012
 * - January 2012
 * - January
 * (in) Jan
 */
class ENMonthNameParser extends AbstractParserWithWordBoundaryChecking {
  @override
  RegExp innerPattern(context) {
    return _pattern;
  }

  @override
  innerExtract(ParsingContext context, RegExpChronoMatch match) {
    final monthName = match[_MONTH_NAME_GROUP]!.toLowerCase();

    // skip some unlikely words "jan", "mar", ..
    if (match[0]!.length <= 3 &&
        FULL_MONTH_NAME_DICTIONARY[monthName] == null) {
      return null;
    }

    final result = context.createParsingResult(
        match.index + (match[_PREFIX_GROUP] ?? "").length,
        match.index + match[0]!.length);
    result.start.imply(Component.day, 1);

    final month = MONTH_DICTIONARY[monthName]!;
    result.start.assign(Component.month, month);

    if (match[_YEAR_GROUP] != null) {
      final year = parseYear(match[_YEAR_GROUP]!)!;
      result.start.assign(Component.year, year);
    } else {
      final year = findYearClosestToRef(context.reference.instant, 1, month);
      result.start.imply(Component.year, year);
    }

    return result;
  }
}
