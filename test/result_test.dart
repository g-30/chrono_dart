import 'package:test/test.dart';
import 'package:chrono_dart/src/types.dart' show Component;
import 'package:chrono_dart/src/results.dart'
    show ParsingComponents, ParsingResult, ReferenceWithTimezone;

void main() {
  test("Test - Create & manipulate parsing components", () {
    final reference = ReferenceWithTimezone(DateTime.now());
    final components = ParsingComponents(reference,
        {Component.year: 2014, Component.month: 11, Component.day: 24});

    expect(components.get(Component.year), 2014);
    expect(components.get(Component.month), 11);
    expect(components.get(Component.day), 24);
    expect(components.date(), isNot(null));
    expect(components.tags().length, 0);

    // null
    expect(components.get(Component.weekday), isNull);
    expect(components.isCertain(Component.weekday), false);

    // "imply"
    components.imply(Component.weekday, 1);
    expect(components.get(Component.weekday), 1);
    expect(components.isCertain(Component.weekday), false);

    // "assign" overrides "imply"
    components.assign(Component.weekday, 2);
    expect(components.get(Component.weekday), 2);
    expect(components.isCertain(Component.weekday), true);

    // "imply" doesn't override "assign"
    components.imply(Component.year, 2013);
    expect(components.get(Component.year), 2014);

    // "assign" overrides "assign"
    components.assign(Component.year, 2013);
    expect(components.get(Component.year), 2013);

    components.addTag("custom/testing_component_tag");
    expect(components.tags().length, 1);
    expect(components.tags(), contains("custom/testing_component_tag"));
    expect(components.toString(), contains("custom/testing_component_tag"));
  });

  test("Test - Create & manipulate parsing results", () {
    final reference = ReferenceWithTimezone(DateTime.now());
    final text = "1 - 2 hour later";

    final startComponents =
      ParsingComponents.createRelativeFromReference(reference, {"hour": 1})
        .addTag("custom/testing_start_component_tag");

    final endComponents =
      ParsingComponents.createRelativeFromReference(reference, {"hour": 2})
        .addTag("custom/testing_end_component_tag");

    final result =
      ParsingResult(reference, 0, text, startComponents, endComponents);

    // The result's date() should be the same as the start components' date()
    expect(result.date().millisecondsSinceEpoch,
        startComponents.date().millisecondsSinceEpoch);

    // The result's tags should include both the start and end components' tags
    expect(result.tags(), contains("custom/testing_start_component_tag"));
    expect(result.tags(), contains("custom/testing_end_component_tag"));

    // The result's toString() should include the text and tags
    expect(result.toString(), contains(text));
    expect(result.toString(), contains("custom/testing_start_component_tag"));
    expect(result.toString(), contains("custom/testing_end_component_tag"));
  });

  test("Test - Calendar checking with implied components", () {
    final reference = ReferenceWithTimezone(DateTime.now());

    final components = ParsingComponents(reference, {
      Component.day: 13,
      Component.month: 12,
      Component.year: 2021,
      Component.hour: 14,
      Component.minute: 22,
      Component.second: 14,
      Component.millisecond: 0,
    });
    components.imply(Component.timezoneOffset, -300);

    expect(components.isValidDate(), true);
  });

  group("Test - Calendar Checking", () {
    final reference = ReferenceWithTimezone(DateTime.now());

    test('validity - 1', () {
      final components = ParsingComponents(reference,
          {Component.year: 2014, Component.month: 11, Component.day: 24});
      expect(components.isValidDate(), true);
    });

    test('validity - 2', () {
      final components = ParsingComponents(reference, {
        Component.year: 2014,
        Component.month: 11,
        Component.day: 24,
        Component.hour: 12
      });
      expect(components.isValidDate(), true);
    });

    test('validity - 3', () {
      final components = ParsingComponents(reference, {
        Component.year: 2014,
        Component.month: 11,
        Component.day: 24,
        Component.hour: 12,
        Component.minute: 30
      });
      expect(components.isValidDate(), true);
    });

    test('validity - 4', () {
      final components = ParsingComponents(reference, {
        Component.year: 2014,
        Component.month: 11,
        Component.day: 24,
        Component.hour: 12,
        Component.minute: 30,
        Component.second: 30,
      });
      expect(components.isValidDate(), true);
    });

    test('validity - 5', () {
      final components = ParsingComponents(reference,
          {Component.year: 2014, Component.month: 13, Component.day: 24});
      expect(components.isValidDate(), false);
    });

    test('validity - 6', () {
      final components = ParsingComponents(reference,
          {Component.year: 2014, Component.month: 11, Component.day: 32});
      expect(components.isValidDate(), false);
    });

    test('validity - 7', () {
      final components = ParsingComponents(reference, {
        Component.year: 2014,
        Component.month: 11,
        Component.day: 24,
        Component.hour: 24
      });
      expect(components.isValidDate(), false);
    });

    test('validity - 8', () {
      final components = ParsingComponents(reference, {
        Component.year: 2014,
        Component.month: 11,
        Component.day: 24,
        Component.hour: 12,
        Component.minute: 60
      });
      expect(components.isValidDate(), false);
    });

    test('validity - 9', () {
      final components = ParsingComponents(reference, {
        Component.year: 2014,
        Component.month: 11,
        Component.day: 24,
        Component.hour: 12,
        Component.minute: 30,
        Component.second: 60,
      });
      expect(components.isValidDate(), false);
    });
  });
}
