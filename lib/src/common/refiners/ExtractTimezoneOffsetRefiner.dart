import '../../chrono.dart' show ParsingContext, Refiner;
import '../../types.dart' show Component;
import '../../results.dart' show ParsingResult;

final TIMEZONE_OFFSET_PATTERN = RegExp(
    "^\\s*(?:\\(?(?:GMT|UTC)\\s?)?([+-])(\\d{1,2})(?::?(\\d{2}))?\\)?",
    caseSensitive: false);
const _TIMEZONE_OFFSET_SIGN_GROUP = 1;
const _TIMEZONE_OFFSET_HOUR_OFFSET_GROUP = 2;
const _TIMEZONE_OFFSET_MINUTE_OFFSET_GROUP = 3;

class ExtractTimezoneOffsetRefiner implements Refiner {
  @override
  List<ParsingResult> refine(
      ParsingContext context, List<ParsingResult> results) {
    for (final result in results) {
      if (result.start.isCertain(Component.timezoneOffset)) {
        return [];
      }

      final suffix = context.text.substring(result.index + result.text.length);
      final match = TIMEZONE_OFFSET_PATTERN.firstMatch(suffix);
      if (match == null) {
        return [];
      }

      context.debug(
          () => {print("Extracting timezone: '${match[0]}' into : $result")});

      final hourOffset = int.parse(match[_TIMEZONE_OFFSET_HOUR_OFFSET_GROUP]!);
      final minuteOffset =
          int.parse(match[_TIMEZONE_OFFSET_MINUTE_OFFSET_GROUP] ?? "0");
      var timezoneOffset = hourOffset * 60 + minuteOffset;
      // No timezones have offsets greater than 14 hours, so disregard this match
      if (timezoneOffset > 14 * 60) {
        return [];
      }
      if (match[_TIMEZONE_OFFSET_SIGN_GROUP] == "-") {
        timezoneOffset = -timezoneOffset;
      }

      if (result.end != null) {
        result.end!.assign(Component.timezoneOffset, timezoneOffset);
      }

      result.start.assign(Component.timezoneOffset, timezoneOffset);
      result.text += match[0]!;
    }

    return results;
  }
}
