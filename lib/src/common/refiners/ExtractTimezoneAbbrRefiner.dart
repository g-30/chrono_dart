// Map ABBR -> Offset in minute
import '../../chrono.dart' show ParsingContext, Refiner;
import '../../types.dart' show TimezoneAbbrMap, Component;
import '../../results.dart' show ParsingResult;
import '../../timezone.dart' show toTimezoneOffset;

// ignore: non_constant_identifier_names
final TIMEZONE_NAME_PATTERN = RegExp("^\\s*,?\\s*\\(?([A-Z]{2,4})\\)?(?=\\W|\$)", caseSensitive: false);

class ExtractTimezoneAbbrRefiner implements Refiner {
  final TimezoneAbbrMap? timezoneOverrides;
    ExtractTimezoneAbbrRefiner([ this.timezoneOverrides ]);

    @override
      List<ParsingResult> refine(ParsingContext context, List<ParsingResult> results) {
        final timezoneOverrides = context.option.timezones ?? {};

for (final result in results) {
            final suffix = context.text.substring(result.index + result.text.length);
            final match = TIMEZONE_NAME_PATTERN.firstMatch(suffix);
            if (match == null) {
                return [];
            }

            final timezoneAbbr = match[1]!.toUpperCase();
            final refDate = result.start.date(); // ?? result.refDate ?? DateTime.now();
            final tzOverrides = { ...(this.timezoneOverrides ?? {}), ...timezoneOverrides };
            final extractedTimezoneOffset = toTimezoneOffset(timezoneAbbr, refDate, tzOverrides);
            if (extractedTimezoneOffset == null) {
                return [];
            }
            context.debug(() => {
                print(
                    "Extracting timezone: '$timezoneAbbr' into: $extractedTimezoneOffset for: ${result.start}"
                )
            });

            final currentTimezoneOffset = result.start.get(Component.timezoneOffset);
            if (currentTimezoneOffset != null && extractedTimezoneOffset != currentTimezoneOffset) {
                // We may already have extracted the timezone offset e.g. "11 am GMT+0900 (JST)"
                // - if they are equal, we also want to take the abbreviation text into result
                // - if they are not equal, we trust the offset more
                if (result.start.isCertain(Component.timezoneOffset)) {
                    return [];
                }

                // This is often because it's relative time with inferred timezone (e.g. in 1 hour, tomorrow)
                // Then, we want to double-check the abbr case (e.g. "GET" not "get")
                if (timezoneAbbr != match[1]) {
                    return [];
                }
            }

            if (result.start.isOnlyDate()) {
                // If the time is not explicitly mentioned,
                // Then, we also want to double-check the abbr case (e.g. "GET" not "get")
                if (timezoneAbbr != match[1]) {
                    return [];
                }
            }

            result.text += match[0]!;

            if (!result.start.isCertain(Component.timezoneOffset)) {
                result.start.assign(Component.timezoneOffset, extractedTimezoneOffset);
            }

            if (result.end != null && !result.end!.isCertain(Component.timezoneOffset)) {
                result.end!.assign(Component.timezoneOffset, extractedTimezoneOffset);
            }
        }

        return results;
    }
}
