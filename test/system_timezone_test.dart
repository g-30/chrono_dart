import 'package:test/test.dart';
import 'package:chrono_dart/chrono_dart.dart';
import './test_util.dart' show testSingleCase, toBeDate;

void main() {
  final chrono = Chrono();
  test("Test - Timezone difference on reference example", () {
    testSingleCase(
        chrono,
        "Friday at 4pm",
        ParsingReference(
          instant: DateTime.parse("2021-06-09T07:00:00-05:00"),
          timezone: "CDT",
        ), (result) {
      expect(result, toBeDate(DateTime.parse("2021-06-11T16:00:00-05:00")));
      expect(result, toBeDate(DateTime.parse("2021-06-12T06:00:00+09:00")));
    });
  });

  test("Test - Timezone difference on default timezone", () {
    final INPUT = "Friday at 4pm";
    final REF_INSTANT = DateTime(2021, 6, 9, 7, 0, 0);
    final EXPECTED_INSTANT = DateTime(2021, 6, 11, 16, 0, 0);

    testSingleCase(chrono, INPUT, REF_INSTANT, (result) {
      expect(result, toBeDate(EXPECTED_INSTANT));
    });

    testSingleCase(chrono, INPUT,
        ParsingReference(instant: REF_INSTANT),
        (result) {
      expect(result, toBeDate(EXPECTED_INSTANT));
    });

    testSingleCase(
        chrono,
        INPUT,
        
            ParsingReference(instant: REF_INSTANT, timezone: null), (result) {
      expect(result, toBeDate(EXPECTED_INSTANT));
    });

    testSingleCase(
        chrono,
        INPUT,
        
            ParsingReference(instant: REF_INSTANT, timezone: ""), (result) {
      expect(result, toBeDate(EXPECTED_INSTANT));
    });
  });

  test("Test - Timezone difference on reference date", () {
    // 2021-06-06T19:00:00+09:00
    // 2021-06-06T11:00:00+01:00
    final refInstant = DateTime.parse("2021-06-06T19:00:00+09:00");

    testSingleCase(
        chrono,
        "At 4pm tomorrow",
        
            ParsingReference(instant: refInstant, timezone: "BST"), (result) {
      final expectedInstant = DateTime.parse("2021-06-07T16:00:00+01:00");
      expect(result, toBeDate(expectedInstant));
    });

    testSingleCase(
        chrono,
        "At 4pm tomorrow",
        
            ParsingReference(instant: refInstant, timezone: "JST"), (result) {
      final expectedInstant = DateTime.parse("2021-06-07T16:00:00+09:00");
      expect(result, toBeDate(expectedInstant));
    });
  });

  test("Test - Timezone difference on written date", () {
    // 2021-06-06T19:00:00+09:00
    // 2021-06-06T11:00:00+01:00
    final refInstant = DateTime.parse("2021-06-06T19:00:00+09:00");

    testSingleCase(chrono, "2021-06-06T19:00:00",
        ParsingReference(timezone: "JST"), (result) {
      expect(result, toBeDate(refInstant));
    });

    testSingleCase(chrono, "2021-06-06T11:00:00",
        ParsingReference(timezone: "BST"), (result) {
      expect(result, toBeDate(refInstant));
    });

    testSingleCase(chrono, "2021-06-06T11:00:00",
        ParsingReference(timezone: 60), (result) {
      expect(result, toBeDate(refInstant));
    });
  });

  test("Test - Precise [now] mentioned", () {
    final refDate = DateTime.parse("2021-13-03T14:22:14+09:00");

    testSingleCase(chrono, "now", refDate, (result) {
      expect(result, toBeDate(refDate));
    });

    testSingleCase(chrono, "now",
        ParsingReference(instant: refDate), (result) {
      expect(result, toBeDate(refDate));
    });

    testSingleCase(
        chrono,
        "now",
        
            ParsingReference(instant: refDate, timezone: 540), (result) {
      expect(result, toBeDate(refDate));
    });

    testSingleCase(
        chrono,
        "now",
        
            ParsingReference(instant: refDate, timezone: "JST"), (result) {
      expect(result, toBeDate(refDate));
    });

    testSingleCase(
        chrono,
        "now",
        
            ParsingReference(instant: refDate, timezone: -300), (result) {
      expect(result, toBeDate(refDate));
    });
  });

  test("Test - Precise date/time mentioned", () {
    final text = "Sat Mar 13 2021 14:22:14+09:00";
    final dartDate = DateTime.parse('2021-03-13T14:22:14+09:00');
    final refDate = DateTime.now();

    testSingleCase(chrono, text, refDate, (result, text) {
      expect(result, toBeDate(dartDate));
    });

    testSingleCase(
        chrono, text, ParsingReference(instant: refDate),
        (result) {
      expect(result, toBeDate(dartDate));
    });

    testSingleCase(
        chrono,
        text,
        
            ParsingReference(instant: refDate, timezone: 540), (result) {
      expect(result, toBeDate(dartDate));
    });

    testSingleCase(
        chrono,
        text,
        
            ParsingReference(instant: refDate, timezone: "JST"), (result) {
      expect(result, toBeDate(dartDate));
    });

    testSingleCase(
        chrono,
        text,
        
            ParsingReference(instant: refDate, timezone: -300), (result) {
      expect(result, toBeDate(dartDate));
    });
  });
}
