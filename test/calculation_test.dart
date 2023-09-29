import 'package:test/test.dart';
import 'package:chrono_dart/src/common/calculation/weekdays.dart'
    show createParsingComponentsAtWeekday, getDaysToWeekday;
import 'package:chrono_dart/src/types.dart' show Weekday;
import 'package:chrono_dart/src/results.dart' show ReferenceWithTimezone;

void main() {
  test("Test - This Weekday Calculation", () {
    (() {
      final reference =
          ReferenceWithTimezone(DateTime.parse("2022-08-20 12:00:00"));
      final output =
          createParsingComponentsAtWeekday(reference, Weekday.MONDAY, "this");
      expect(output.date().toIso8601String(), DateTime.parse("2022-08-22 12:00:00").toIso8601String());
    })();
    (() {
      final reference =
          ReferenceWithTimezone(DateTime.parse("2022-08-21 12:00:00"));
      final output =
          createParsingComponentsAtWeekday(reference, Weekday.FRIDAY, "this");
      expect(output.date().millisecondsSinceEpoch, DateTime.parse("2022-08-26 12:00:00").millisecondsSinceEpoch);
    })();
    (() {
      final reference =
          ReferenceWithTimezone(DateTime.parse("2022-08-02 12:00:00"));
      final output =
          createParsingComponentsAtWeekday(reference, Weekday.SUNDAY, "this");
      expect(output.date().millisecondsSinceEpoch, DateTime.parse("2022-08-07 12:00:00").millisecondsSinceEpoch);
    })();
  });

  test("Test - Last Weekday Calculation", () {
    (() {
      final reference =
          ReferenceWithTimezone(DateTime.parse("2022-08-20 12:00:00"));
      final output =
          createParsingComponentsAtWeekday(reference, Weekday.FRIDAY, "last");
      expect(output.date().millisecondsSinceEpoch, DateTime.parse("2022-08-19 12:00:00").millisecondsSinceEpoch);
    })();
    (() {
      final reference =
          ReferenceWithTimezone(DateTime.parse("2022-08-20 12:00:00"));
      final output =
          createParsingComponentsAtWeekday(reference, Weekday.MONDAY, "last");
      expect(output.date().millisecondsSinceEpoch, DateTime.parse("2022-08-15 12:00:00").millisecondsSinceEpoch);
    })();
    (() {
      final reference =
          ReferenceWithTimezone(DateTime.parse("2022-08-20 12:00:00"));
      final output =
          createParsingComponentsAtWeekday(reference, Weekday.SUNDAY, "last");
      expect(output.date().millisecondsSinceEpoch, DateTime.parse("2022-08-14 12:00:00").millisecondsSinceEpoch);
    })();
    (() {
      final reference =
          ReferenceWithTimezone(DateTime.parse("2022-08-20 12:00:00"));
      final output =
          createParsingComponentsAtWeekday(reference, Weekday.SATURDAY, "last");
      expect(output.date().millisecondsSinceEpoch, DateTime.parse("2022-08-13 12:00:00").millisecondsSinceEpoch);
    })();
  });

  test("Test - Next Weekday Calculation", () {
    (() {
      final reference =
          ReferenceWithTimezone(DateTime.parse("2022-08-21 12:00:00"));
      final output =
          createParsingComponentsAtWeekday(reference, Weekday.MONDAY, "next");
      expect(output.date().millisecondsSinceEpoch, DateTime.parse("2022-08-22 12:00:00").millisecondsSinceEpoch);
    })();
    (() {
      final reference =
          ReferenceWithTimezone(DateTime.parse("2022-08-21 12:00:00"));
      final output =
          createParsingComponentsAtWeekday(reference, Weekday.SATURDAY, "next");
      expect(output.date().millisecondsSinceEpoch, DateTime.parse("2022-08-27 12:00:00").millisecondsSinceEpoch);
    })();
    (() {
      final reference =
          ReferenceWithTimezone(DateTime.parse("2022-08-21 12:00:00"));
      final output =
          createParsingComponentsAtWeekday(reference, Weekday.SUNDAY, "next");
      expect(output.date().millisecondsSinceEpoch, DateTime.parse("2022-08-28 12:00:00").millisecondsSinceEpoch);
    })();
    (() {
      final reference =
          ReferenceWithTimezone(DateTime.parse("2022-08-20 12:00:00"));
      final output =
          createParsingComponentsAtWeekday(reference, Weekday.FRIDAY, "next");
      expect(output.date().millisecondsSinceEpoch, DateTime.parse("2022-08-26 12:00:00").millisecondsSinceEpoch);
    })();
    (() {
      final reference =
          ReferenceWithTimezone(DateTime.parse("2022-08-20 12:00:00"));
      final output =
          createParsingComponentsAtWeekday(reference, Weekday.SATURDAY, "next");
      expect(output.date().millisecondsSinceEpoch, DateTime.parse("2022-08-27 12:00:00").millisecondsSinceEpoch);
    })();
    (() {
      final reference =
          ReferenceWithTimezone(DateTime.parse("2022-08-20 12:00:00"));
      final output =
          createParsingComponentsAtWeekday(reference, Weekday.SUNDAY, "next");
      expect(output.date().millisecondsSinceEpoch, DateTime.parse("2022-08-28 12:00:00").millisecondsSinceEpoch);
    })();
    (() {
      final reference =
          ReferenceWithTimezone(DateTime.parse("2022-08-02 12:00:00"));
      final output =
          createParsingComponentsAtWeekday(reference, Weekday.MONDAY, "next");
      expect(output.date().millisecondsSinceEpoch, DateTime.parse("2022-08-08 12:00:00").millisecondsSinceEpoch);
    })();
    (() {
      final reference =
          ReferenceWithTimezone(DateTime.parse("2022-08-02 12:00:00"));
      final output =
          createParsingComponentsAtWeekday(reference, Weekday.FRIDAY, "next");
      expect(output.date().millisecondsSinceEpoch, DateTime.parse("2022-08-12 12:00:00").millisecondsSinceEpoch);
    })();

    (() {
      final reference =
          ReferenceWithTimezone(DateTime.parse("2022-08-02 12:00:00"));
      final output =
          createParsingComponentsAtWeekday(reference, Weekday.SUNDAY, "next");
      expect(output.date().millisecondsSinceEpoch, DateTime.parse("2022-08-14 12:00:00").millisecondsSinceEpoch);
    })();
  });

  test("Test - Closest Weekday Calculation", () {
    (() {
      final refDate = DateTime.parse("2022-08-20");
      expect(getDaysToWeekday(refDate, Weekday.MONDAY), 2);
    })();
    (() {
      final refDate = DateTime.parse("2022-08-20");
      expect(getDaysToWeekday(refDate, Weekday.TUESDAY), 3);
    })();
    (() {
      final refDate = DateTime.parse("2022-08-20");
      expect(getDaysToWeekday(refDate, Weekday.FRIDAY), -1);
    })();
    (() {
      final refDate = DateTime.parse("2022-08-20");
      expect(getDaysToWeekday(refDate, Weekday.THURSDAY), -2);
    })();
    (() {
      final refDate = DateTime.parse("2022-08-20");
      expect(getDaysToWeekday(refDate, Weekday.WEDNESDAY), -3);
    })();
  });
}
