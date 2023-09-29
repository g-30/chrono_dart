// ignore_for_file: prefer_interpolation_to_compose_strings, constant_identifier_names
import '../../../chrono.dart' show ParsingContext;
import '../../../types.dart' show RegExpChronoMatch, Component;
import '../constants.dart' show MONTH_DICTIONARY;
import '../../../utils/pattern.dart' show matchAnyPattern;
import '../../../common/parsers/AbstractParserWithWordBoundary.dart';

/*
    Date format with slash "/" between numbers like ENSlashDateFormatParser,
    but this parser expect year before month and date.
    - YYYY/MM/DD
    - YYYY-MM-DD
    - YYYY.MM.DD
*/
final _pattern = RegExp(
    // ignore: prefer_adjacent_string_concatenation
    "([0-9]{4})[\\.\\/\\s]" +
        "(?:(${matchAnyPattern(MONTH_DICTIONARY)})|([0-9]{1,2}))[\\.\\/\\s]" +
        "([0-9]{1,2})" +
        "(?=\\W|\$)",
    caseSensitive: false);

const _YEAR_NUMBER_GROUP = 1;
const _MONTH_NAME_GROUP = 2;
const _MONTH_NUMBER_GROUP = 3;
const _DATE_NUMBER_GROUP = 4;

class ENCasualYearMonthDayParser
    extends AbstractParserWithWordBoundaryChecking {
  @override
  RegExp innerPattern(context) {
    return _pattern;
  }

  @override
  Map<Component, int>? innerExtract(
      ParsingContext context, RegExpChronoMatch match) {
    final month = match[_MONTH_NUMBER_GROUP] != null
        ? int.parse(match[_MONTH_NUMBER_GROUP]!)
        : MONTH_DICTIONARY[match[_MONTH_NAME_GROUP]!.toLowerCase()]!;

    if (month < 1 || month > 12) {
      return null;
    }

    final year = int.parse(match[_YEAR_NUMBER_GROUP]!);
    final day = int.parse(match[_DATE_NUMBER_GROUP]!);

    return {
      Component.day: day,
      Component.month: month,
      Component.year: year,
    };
  }
}
