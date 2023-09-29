// ignore_for_file: constant_identifier_names
import '../../../types.dart';
import '../../../chrono.dart' show ParsingContext;
import '../../../results.dart' show ParsingComponents;
import '../constants.dart' show WEEKDAY_DICTIONARY;
import '../../../utils/pattern.dart' show matchAnyPattern;
import '../../../common/parsers/AbstractParserWithWordBoundary.dart'
    show AbstractParserWithWordBoundaryChecking;
import '../../../common/calculation/weekdays.dart'
    show createParsingComponentsAtWeekday;

final _pattern = RegExp(
  // ignore: prefer_interpolation_to_compose_strings, prefer_adjacent_string_concatenation
  "(?:(?:\\,|\\(|\\（)\\s*)?" +
      "(?:on\\s*?)?" +
      "(?:(this|last|past|next)\\s*)?" +
      "(${matchAnyPattern(WEEKDAY_DICTIONARY)})" +
      "(?:\\s*(?:\\,|\\)|\\）))?" +
      "(?:\\s*(this|last|past|next)\\s*week)?" +
      "(?=\\W|\$)",
  caseSensitive: true,
);

const _PREFIX_GROUP = 1;
const _WEEKDAY_GROUP = 2;
const _POSTFIX_GROUP = 3;

class ENWeekdayParser extends AbstractParserWithWordBoundaryChecking {
  @override
  RegExp innerPattern(context) {
    return _pattern;
  }

  @override
  ParsingComponents innerExtract(
      ParsingContext context, RegExpChronoMatch match) {
    final dayOfWeek = match[_WEEKDAY_GROUP]!.toLowerCase();

    /// TODO: remove assumed weekday if null
    final weekday = Weekday.weekById(WEEKDAY_DICTIONARY[dayOfWeek] ?? 0);
    final prefix = match[_PREFIX_GROUP];
    final postfix = match[_POSTFIX_GROUP];
    var modifierWord = prefix ?? postfix;
    modifierWord = modifierWord ?? "";
    modifierWord = modifierWord.toLowerCase();

    String? modifier;
    if (modifierWord == "last" || modifierWord == "past") {
      modifier = "last";
    } else if (modifierWord == "next") {
      modifier = "next";
    } else if (modifierWord == "this") {
      modifier = "this";
    }

    return createParsingComponentsAtWeekday(
        context.reference, weekday, modifier);
  }
}
