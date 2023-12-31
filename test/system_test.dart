import 'package:chrono_dart/src/common/parsers/ISOFormatParser.dart';
import 'package:test/test.dart';
import 'package:chrono_dart/chrono_dart.dart';
import 'package:chrono_dart/src/common/refiners/UnlikelyFormatFilter.dart';
import 'package:chrono_dart/src/locales/en/parsers/ENTimeUnitCasualRelativeFormatParser.dart';
// import 'package:chrono_dart/src/locales/en/parsers/ENWeekdayParser.dart';
import './test_util.dart' show testSingleCase, testUnexpectedResult, toBeDate;

void main() {
  test("Test - Load modules", () {
    expect(Chrono, isNotNull);

    expect(Chrono.parse, isNotNull);

    expect(Chrono.parseDate, isNotNull);

    expect(Chrono.casual, isNotNull);

    expect(Chrono.strict, isNotNull);
  });

  test("Test - Basic parse date functions", () {
    expect(Chrono.parseDate("7:00PM July 5th, 2020")?.millisecondsSinceEpoch,
        DateTime(2020, 7, 5, 19).millisecondsSinceEpoch);

    expect(
        Chrono.strict
            .parseDate("7:00PM July 5th, 2020")
            ?.millisecondsSinceEpoch,
        DateTime(2020, 7, 5, 19).millisecondsSinceEpoch);

    expect(
        Chrono.casual
            .parseDate("7:00PM July 5th, 2020")
            ?.millisecondsSinceEpoch,
        DateTime(2020, 7, 5, 19).millisecondsSinceEpoch);
  });

/*test("Test - Add custom parser", () {
    final Chrono.Parser customParser = {
        pattern: () {
            return /(\d{1,2})(st|nd|rd|th)/i;
        },
        extract: (context, match) {
            expect(match[0], "25th");
            expect(context.refDate).toBeTruthy();

            return {
                day: parseInt(match[1]),
            };
        },
    };

    final custom = Chrono.Chrono();
    custom.parsers.add(customParser);
    testSingleCase(custom, "meeting on 25th", DateTime(2017, 11, 19), (result) {
        expect(result.text, "25th");
        expect(result.start.get(Component.month), 11);
        expect(result.start.get(Component.day), 25);
    });
});

test("Test - Add custom parser example", () {
    final custom = Chrono.casual.clone();
    custom.parsers.add({
        pattern: () {
            return /\bChristmas\b/i;
        },
        extract: () {
            return {
                day: 25,
                month: 12,
            };
        },
    });

    testSingleCase(custom, "I'll arrive at 2.30AM on Christmas", (result) {
        expect(result.text, "at 2.30AM on Christmas");
        expect(result.start.get(Component.month), 12);
        expect(result.start.get(Component.day), 25);
        expect(result.start.get(Component.hour), 2);
        expect(result.start.get(Component.minute), 30);
    });

    testSingleCase(custom, "I'll arrive at Christmas night", (result) {
        expect(result.text, "Christmas night");
        expect(result.start.get(Component.month), 12);
        expect(result.start.get(Component.day), 25);
        expect(result.start.get(Component.meridiem), Meridiem.PM);
        expect(result.start.get(Component.meridiem), 1);
    });

    testSingleCase(custom, "Doing something tomorrow", (result) {
        expect(result.text, "tomorrow");
    });
});

test("Test - Add custom refiner example", () {
    final custom = Chrono.casual.clone();
    custom.refiners.add({
        refine: (context, results) {
            // If there is no AM/PM (meridiem) specified,
            //  let all time between 1:00 - 4:00 be PM (13.00 - 16.00)
            results.forEach((result) {
                if (
                    !result.start.isCertain("meridiem") &&
                    result.start.get(Component.hour) >= 1 &&
                    result.start.get(Component.hour) < 4
                ) {
                    result.start.assign(Component.meridiem, Meridiem.PM);
                    result.start.assign(Component.hour, result.start.get(Component.hour) + 12);
                }
            });
            return results;
        },
    });

    testSingleCase(custom, "This is at 2.30", (result) {
        expect(result.text, "at 2.30");
        expect(result.start.get(Component.hour), 14);
        expect(result.start.get(Component.minute), 30);
    });

    testSingleCase(custom, "This is at 2.30 AM", (result) {
        expect(result.text, "at 2.30 AM");
        expect(result.start.get(Component.hour), 2);
        expect(result.start.get(Component.minute), 30);
    });
});

test("Test - Add custom parser with tags example", () {
    final custom = Chrono.casual.clone();
    custom.parsers.add({
        pattern: () {
            return /\bChristmas\b/i;
        },
        extract: (context) {
            return context
                .createParsingComponents({
                    Component.day: 25,
                    Component.month: 12,
                })
                .addTag("parser/ChristmasDayParser");
        },
    });

    testSingleCase(custom, "Doing something tomorrow", (result) {
        expect(result.text, "tomorrow");
        expect(result.tags(), contains("parser/ENCasualDateParser"));
    });

    testSingleCase(custom, "I'll arrive at 2.30AM on Christmas", (result) {
        expect(result.text, "at 2.30AM on Christmas");
        expect(result.tags(), contains("parser/ChristmasDayParser"));
        expect(result.tags(), contains("parser/ENTimeExpressionParser"));
    });

    testSingleCase(custom, "I'll arrive at Christmas night", (result) {
        expect(result.text, "Christmas night");
        expect(result.tags(), contains("parser/ChristmasDayParser"));
        expect(result.tags(), contains("parser/ENCasualTimeParser"));
    });

    // TODO: Check if the merge date range combine tags correctly
});*/

  test("Test - Remove parsers example", () {
    final custom = Chrono.strict.clone();
    custom.parsers =
        custom.parsers.whereType<ISOFormatParser>().toList();
    // custom.parsers.add(ISOFormatParser());

    testSingleCase(custom, "2018-10-06", (result) {
      expect(result.text, "2018-10-06");
      expect(result.start.get(Component.year), 2018);
      expect(result.start.get(Component.month), 10);
      expect(result.start.get(Component.day), 6);
    });
  });

  test("Test - Remove a refiner example", () {
    final custom = Chrono.casual.clone();
    custom.refiners =
        custom.refiners.where((r) => r is! UnlikelyFormatFilter).toList();

    testSingleCase(custom, "This is at 2.30", (result) {
      expect(result.text, "at 2.30");
      expect(result.start.get(Component.hour), 2);
      expect(result.start.get(Component.minute), 30);
    });
  });

  test("Test - Replace a parser example", () {
    final custom = Chrono.casual.clone();
    testSingleCase(custom, "next 5m", DateTime(2016, 10, 1, 14, 52),
        (result, text) {
      expect(result.start.get(Component.hour), 14);
      expect(result.start.get(Component.minute), 57);
    });
    testSingleCase(custom, "next 5 minutes", DateTime(2016, 10, 1, 14, 52),
        (result, text) {
      expect(result.start.get(Component.hour), 14);
      expect(result.start.get(Component.minute), 57);
    });

    final index = custom.parsers
        .indexWhere((r) => r is ENTimeUnitCasualRelativeFormatParser);
    custom.parsers[index] = ENTimeUnitCasualRelativeFormatParser(false);
    testUnexpectedResult(custom, "next 5m");
    testSingleCase(custom, "next 5 minutes", DateTime(2016, 10, 1, 14, 52),
        (result, text) {
      expect(result.start.get(Component.hour), 14);
      expect(result.start.get(Component.minute), 57);
    });
  });

  test("Test - Simple date parse", () {
    final chronoInst = Chrono.casual;
    final date = chronoInst.parseDate("I'll see you next Monday at 3pm", DateTime(2023, 10, 05));
    expect(date, isNotNull);
    expect(date, toBeDate(DateTime(2023, 10, 09, 15)));
  });

  test("Test - Tomorrow", () {
    final chronoInst = Chrono.casual;
    final res = chronoInst.parse("I'll see you tomorrow at 7pm!", DateTime(2023, 10, 05));
    final date = res.firstOrNull?.date();
    expect(date, isNotNull);
    expect(date, toBeDate(DateTime(2023, 10, 06, 19)));
  });

  test("Test - Day after tomorrow", () {
    final chronoInst = Chrono.casual;
    final res = chronoInst.parse("I'll see you the day after tomorrow at 6pm!", DateTime(2023, 10, 05));
    final date = res.firstOrNull?.date();
    expect(date, isNotNull);
    expect(date, toBeDate(DateTime(2023, 10, 07, 18)));
  });

  test("Test - yesterday", () {
    final chronoInst = Chrono.casual;
    final res = chronoInst.parse("We had a meeting yesterday at 8am!", DateTime(2023, 10, 05));
    final date = res.firstOrNull?.date();
    expect(date, isNotNull);
    expect(date, toBeDate(DateTime(2023, 10, 04, 8)));
  });

  test("Test - Compare with native dart", () {
    final chronoInst = Chrono.instance;

    void testByCompareWithNative(text) {
      final expectedDate = DateTime.parse(text);
      testSingleCase(chronoInst, text, (result) {
        expect(result.text, text);
        expect(result, toBeDate(expectedDate));
      });
    }

    testByCompareWithNative("1994-11-05T13:15:30Z");

    testByCompareWithNative("1994-02-28T08:15:30-05:30");

    testByCompareWithNative("1994-11-05T08:15:30-05:30");

    testByCompareWithNative("1994-11-05T08:15:30+11:30");

    testByCompareWithNative("2014-11-30T08:15:30-05:30");

    testByCompareWithNative("1900-01-01T00:00:00-01:00");

    testByCompareWithNative("1900-01-01T00:00:00-00:00");

    testByCompareWithNative("9999-12-31T23:59:00-00:00");

    testByCompareWithNative("20170925 22:31:50.522");

    testByCompareWithNative("2014-12-14T18:22:14.759Z");
  });
}
