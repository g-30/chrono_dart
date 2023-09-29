// ignore_for_file: prefer_interpolation_to_compose_strings, constant_identifier_names, prefer_adjacent_string_concatenation
import '../../chrono.dart' show Parser, ParsingContext;
import '../../results.dart' show ParsingResult;
import '../../types.dart' show Component, RegExpChronoMatch;
import '../../calculation/years.dart'
    show findMostLikelyADYear, findYearClosestToRef;

/// Date format with slash "/" (or dot ".") between numbers.
/// For examples:
/// - 7/10
/// - 7/12/2020
/// - 7.12.2020
// ignore: non_constant_identifier_names
final _PATTERN = RegExp(
  "([^\\d]|^)" +
      "([0-3]{0,1}[0-9]{1})[\\/\\.\\-]([0-3]{0,1}[0-9]{1})" +
      "(?:[\\/\\.\\-]([0-9]{4}|[0-9]{2}))?" +
      "(\\W|\$)",
  caseSensitive: false,
);

const _OPENING_GROUP = 1;
const _ENDING_GROUP = 5;

const _FIRST_NUMBERS_GROUP = 2;
const _SECOND_NUMBERS_GROUP = 3;

const _YEAR_GROUP = 4;

class SlashDateFormatParser implements Parser {
  int groupNumberMonth;
  int groupNumberDay;

  SlashDateFormatParser(bool littleEndian)
      : groupNumberMonth =
            littleEndian ? _SECOND_NUMBERS_GROUP : _FIRST_NUMBERS_GROUP,
        groupNumberDay =
            littleEndian ? _FIRST_NUMBERS_GROUP : _SECOND_NUMBERS_GROUP;

  @override
  RegExp pattern(context) {
    return _PATTERN;
  }

  @override
  ParsingResult? extract(ParsingContext context, RegExpChronoMatch match) {
    // Because of how pattern is executed on remaining text in `chrono.ts`, the character before the match could
    // still be a number (e.g. X[X/YY/ZZ] or XX[/YY/ZZ] or [XX/YY/]ZZ). We want to check and skip them.
    if (match[_OPENING_GROUP]!.isEmpty &&
        match.index > 0 &&
        match.index < context.text.length) {
      final previousChar = int.tryParse(context.text[match.index - 1]);
      if (previousChar != null) {
        return null;
      }
    }

    final index = match.index + match[_OPENING_GROUP]!.length;
    final text = match[0]!.substring(match[_OPENING_GROUP]!.length,
        match[0]!.length - match[_ENDING_GROUP]!.length);

    // '1.12', '1.12.12' is more like a version numbers
    if (RegExp(r'^\d\.\d$').hasMatch(text) ||
        RegExp(r'^\d\.\d{1,2}\.\d{1,2}\s*$').hasMatch(text)) {
      return null;
    }

    // MM/dd -> OK
    // MM.dd -> NG
    if (match[_YEAR_GROUP] == null && !match[0]!.contains("/")) {
      return null;
    }

    final result = context.createParsingResult(index, text);
    var month = int.parse(match[groupNumberMonth]!);
    var day = int.parse(match[groupNumberDay]!);

    if (month < 1 || month > 12) {
      if (month > 12) {
        if (day >= 1 && day <= 12 && month <= 31) {
          [day, month] = [month, day];
        } else {
          return null;
        }
      }
    }

    if (day < 1 || day > 31) {
      return null;
    }

    result.start.assign(Component.day, day);
    result.start.assign(Component.month, month);

    if (match[_YEAR_GROUP] != null) {
      final rawYearNumber = int.parse(match[_YEAR_GROUP]!);
      final year = findMostLikelyADYear(rawYearNumber);
      result.start.assign(Component.year, year);
    } else {
      final year = findYearClosestToRef(context.reference.instant, day, month);
      result.start.imply(Component.year, year);
    }

    return result;
  }
}
