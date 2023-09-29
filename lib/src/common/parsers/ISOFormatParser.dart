// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_adjacent_string_concatenation, constant_identifier_names
import '../../chrono.dart' show ParsingContext;
import '../../types.dart' show Component, RegExpChronoMatch;
import './AbstractParserWithWordBoundary.dart';

// ISO 8601
// http://www.w3.org/TR/NOTE-datetime
// - YYYY-MM-DD
// - YYYY-MM-DDThh:mmTZD
// - YYYY-MM-DDThh:mm:ssTZD
// - YYYY-MM-DDThh:mm:ss.sTZD
// - TZD = (Z or +hh:mm or -hh:mm)

// prettier-ignore
final _pattern = RegExp(
    "([0-9]{4})\\-([0-9]{1,2})\\-([0-9]{1,2})" +
        "(?:T" + //..
        "([0-9]{1,2}):([0-9]{1,2})" + // hh:mm
        "(?:" +
        ":([0-9]{1,2})(?:\\.(\\d{1,4}))?" +
        ")?" + // :ss.s
        "(?:" +
        "Z|([+-]\\d{2}):?(\\d{2})?" +
        ")?" + // TZD (Z or ±hh:mm or ±hhmm or ±hh)
        ")?" +
        "(?=\\W|\$)",
    caseSensitive: false);

const _YEAR_NUMBER_GROUP = 1;
const _MONTH_NUMBER_GROUP = 2;
const _DATE_NUMBER_GROUP = 3;
const _HOUR_NUMBER_GROUP = 4;
const _MINUTE_NUMBER_GROUP = 5;
const _SECOND_NUMBER_GROUP = 6;
const _MILLISECOND_NUMBER_GROUP = 7;
const _TZD_HOUR_OFFSET_GROUP = 8;
const _TZD_MINUTE_OFFSET_GROUP = 9;

class ISOFormatParser extends AbstractParserWithWordBoundaryChecking {
  @override
  RegExp innerPattern(context) {
    return _pattern;
  }

  @override
  Map<Component, num> innerExtract(
      ParsingContext context, RegExpChronoMatch match) {
    final Map<Component, num> components = {};
    components[Component.year] = int.parse(match[_YEAR_NUMBER_GROUP]!);
    components[Component.month] = int.parse(match[_MONTH_NUMBER_GROUP]!);
    components[Component.day] = int.parse(match[_DATE_NUMBER_GROUP]!);

    if (match[_HOUR_NUMBER_GROUP] != null) {
      components[Component.hour] = int.parse(match[_HOUR_NUMBER_GROUP]!);
      components[Component.minute] = int.parse(match[_MINUTE_NUMBER_GROUP]!);

      if (match[_SECOND_NUMBER_GROUP] != null) {
        components[Component.second] = int.parse(match[_SECOND_NUMBER_GROUP]!);
      }

      if (match[_MILLISECOND_NUMBER_GROUP] != null) {
        components[Component.millisecond] =
            int.parse(match[_MILLISECOND_NUMBER_GROUP]!);
      }

      if (match[_TZD_HOUR_OFFSET_GROUP] == null) {
        components[Component.timezoneOffset] = 0;
      } else {
        final hourOffset = int.parse(match[_TZD_HOUR_OFFSET_GROUP]!);

        var minuteOffset = 0;
        if (match[_TZD_MINUTE_OFFSET_GROUP] != null) {
          minuteOffset = int.parse(match[_TZD_MINUTE_OFFSET_GROUP]!);
        }

        var offset = hourOffset * 60;
        if (offset < 0) {
          offset -= minuteOffset;
        } else {
          offset += minuteOffset;
        }

        components[Component.timezoneOffset] = offset;
      }
    }

    return components;
  }
}
