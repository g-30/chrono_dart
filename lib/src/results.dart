// import 'package:day/plugins/quarter_of_year.dart';
import 'dart:convert';
import 'package:day/day.dart' as day_js;
import './types.dart'
    show Component, ParsedComponents, ParsedResult, ParsingReference;
import './utils/day.dart'
    show assignSimilarDate, assignSimilarTime, implySimilarTime;
import './timezone.dart' show toTimezoneOffset;

class ReferenceWithTimezone {
  final DateTime instant;
  final int? timezoneOffset;

  ReferenceWithTimezone([dynamic input])
      : assert(input == null || input is ParsingReference || input is DateTime),
        instant = (input is DateTime
            ? input
            : ((input is ParsingReference ? input.instant : null) ??
                DateTime.now())).toLocal(),
        timezoneOffset = input is! ParsingReference
            ? null
            : toTimezoneOffset(input.timezone, input.instant);

  /// Returns a Dart date (system timezone) with the { year, month, day, hour, minute, second } equal to the reference.
  /// The output's instant is NOT the reference's instant when the reference's and system's timezone are different.
  getDateWithAdjustedTimezone() {
    return DateTime.fromMillisecondsSinceEpoch(instant.millisecondsSinceEpoch +
        getSystemTimezoneAdjustmentMinute(instant) * 60000);
  }

  /// Returns the number minutes difference between the Dart date's timezone and the reference timezone.
  int getSystemTimezoneAdjustmentMinute(DateTime? date,
      [int? overrideTimezoneOffset]) {
    if (date == null || date.millisecondsSinceEpoch < 0) {
      // TODO: WARNING: Possibly remove due to JS <-> Dart differences?
      // Javascript date timezone calculation got effect when the time epoch < 0
      // e.g. new DateTime('Tue Feb 02 1300 00:00:00 GMT+0900 (JST)') => Tue Feb 02 1300 00:18:59 GMT+0918 (JST)
      date = DateTime.now();
    }

    /// TODO: WARNING: removed negative sign - seems to work as intended, but needs testing.
    final currentTimezoneOffset = date.timeZoneOffset.inMinutes;
    final targetTimezoneOffset =
        overrideTimezoneOffset ?? timezoneOffset ?? currentTimezoneOffset;
    return currentTimezoneOffset - targetTimezoneOffset;
  }

  @override
  String toString() => jsonEncode({
        'instant': instant.toIso8601String(),
        'timezoneOffset': timezoneOffset,
      });
}

class ParsingComponents implements ParsedComponents {
  Map<Component, int> knownValues = {};
  Map<Component, int> impliedValues = {};
  ReferenceWithTimezone reference;
  // ignore: prefer_collection_literals
  final _tags = Set<String>();

  ParsingComponents(this.reference, [Map<Component, int>? knownComponents]) {
    knownValues = {};
    impliedValues = {};
    if (knownComponents != null) {
      for (final key in knownComponents.keys) {
        if (knownComponents[key] != null) {
          knownValues[key] = knownComponents[key]!;
        }
      }
    }

    final refDayJs = day_js.Day.fromDateTime(reference.instant);
    imply(Component.day, refDayJs.date());
    imply(Component.month, refDayJs.month());
    imply(Component.year, refDayJs.year());
    imply(Component.hour, 12);
    imply(Component.minute, 0);
    imply(Component.second, 0);
    imply(Component.millisecond, 0);
  }

  @override
  int? get(Component component) {
    if (knownValues.containsKey(component)) {
      return knownValues[component];
    }

    if (impliedValues.containsKey(component)) {
      return impliedValues[component];
    }

    return null;
  }

  @override
  bool isCertain(Component component) {
    return knownValues.containsKey(component);
  }

  List<Component> getCertainComponents() {
    return knownValues.keys.toList();
  }

  ParsingComponents imply(Component component, int value) {
    if (knownValues.containsKey(component)) {
      return this;
    }
    impliedValues[component] = value;
    return this;
  }

  ParsingComponents assign(Component component, int value) {
    knownValues[component] = value;
    impliedValues.remove(component);
    return this;
  }

  void delete(Component component) {
    knownValues.remove(component);
    impliedValues.remove(component);
  }

  ParsingComponents clone() {
    final component = ParsingComponents(reference);
    component.knownValues = {};
    component.impliedValues = {};

    for (final key in knownValues.keys) {
      component.knownValues[key] = knownValues[key]!;
    }

    for (final key in impliedValues.keys) {
      component.impliedValues[key] = impliedValues[key]!;
    }

    return component;
  }

  bool isOnlyDate() {
    return !isCertain(Component.hour) &&
        !isCertain(Component.minute) &&
        !isCertain(Component.second);
  }

  bool isOnlyTime() {
    return !isCertain(Component.weekday) &&
        !isCertain(Component.day) &&
        !isCertain(Component.month);
  }

  bool isOnlyWeekdayComponent() {
    return isCertain(Component.weekday) &&
        !isCertain(Component.day) &&
        !isCertain(Component.month);
  }

  bool isDateWithUnknownYear() {
    return isCertain(Component.month) && !isCertain(Component.year);
  }

  bool isValidDate() {
    var date = _dateWithoutTimezoneAdjustment();
    if (reference.instant.isUtc) {
      date = date.toUtc();
    }

    if (date.year != get(Component.year)) return false;
    if (date.month != (get(Component.month) ?? 999)) return false;
    if (date.day != get(Component.day)) return false;
    if (get(Component.hour) != null && date.hour != get(Component.hour)) {
      return false;
    }
    if (get(Component.minute) != null && date.minute != get(Component.minute)) {
      return false;
    }

    return true;
  }

  @override
  toString() {
    return '''[ParsingComponents {
            tags: ${jsonEncode(_tags.toList())}, 
            knownValues: ${jsonEncode(knownValues.map((key, val) => MapEntry(key.name, val)))}, 
            impliedValues: ${jsonEncode(impliedValues.map((key, val) => MapEntry(key.name, val)))}}, 
            reference: ${reference.toString()}]''';
  }

  day_js.Day dayjs() {
    return day_js.Day.fromDateTime(date());
  }

  @override
  DateTime date() {
    final date = _dateWithoutTimezoneAdjustment();
    final timezoneAdjustment = reference.getSystemTimezoneAdjustmentMinute(
        date, get(Component.timezoneOffset));
    return DateTime.fromMillisecondsSinceEpoch(
        date.millisecondsSinceEpoch, isUtc: true).add(Duration(minutes: timezoneAdjustment));
  }

  ParsingComponents addTag(String tag) {
    _tags.add(tag);
    return this;
  }

  ParsingComponents addTags(Iterable<String> tags) {
    for (final tag in tags) {
      _tags.add(tag);
    }
    return this;
  }

  @override
  Set<String> tags() {
    return _tags.toSet();
  }

  DateTime _dateWithoutTimezoneAdjustment() {
    return DateTime(
      get(Component.year)!,
      get(Component.month) ?? 1,
      get(Component.day) ?? 1,
      get(Component.hour) ?? 0,
      get(Component.minute) ?? 0,
      get(Component.second) ?? 0,
      get(Component.millisecond) ?? 0,
    );
  }

  static ParsingComponents createRelativeFromReference(
    ReferenceWithTimezone reference,
    Map<String, num> fragments,
  ) {
    var date = day_js.Day.fromDateTime(reference.instant);
    for (final key in fragments.keys) {
      /// TODO: WARNING: forceful double to int; needs research
      date = date.add(fragments[key]!.toInt(), key) ?? date;
    }

    final components = ParsingComponents(reference);
    if (fragments["hour"] != null ||
        fragments["minute"] != null ||
        fragments["second"] != null) {
      assignSimilarTime(components, date);
      assignSimilarDate(components, date);
      if (reference.timezoneOffset != null) {
        components.assign(Component.timezoneOffset,
            -reference.instant.toLocal().timeZoneOffset.inMinutes);
      }
    } else {
      implySimilarTime(components, date);
      if (reference.timezoneOffset != null) {
        components.imply(Component.timezoneOffset,
            -reference.instant.toLocal().timeZoneOffset.inMinutes);
      }

      if (fragments["d"] != null) {
        components.assign(Component.day, date.date());
        components.assign(Component.month, date.month());
        components.assign(Component.year, date.year());
      } else {
        if (fragments["week"] != null) {
          components.imply(Component.weekday, date.weekday());
        }

        components.imply(Component.day, date.date());
        if (fragments["month"] != null) {
          components.assign(Component.month, date.month());
          components.assign(Component.year, date.year());
        } else {
          components.imply(Component.month, date.month());
          if (fragments["year"] != null) {
            components.assign(Component.year, date.year());
          } else {
            components.imply(Component.year, date.year());
          }
        }
      }
    }

    return components;
  }
}

class ParsingResult implements ParsedResult {
  @override
  final DateTime refDate;
  @override
  int index;
  @override
  String text;

  final ReferenceWithTimezone reference;

  @override
  ParsingComponents start;
  @override
  ParsingComponents? end;

  ParsingResult(
    this.reference,
    this.index,
    this.text, [
    ParsingComponents? start,
    this.end,
  ])  : start = start ?? ParsingComponents(reference),
        refDate = reference.instant;

  ParsingResult clone() {
    final result = ParsingResult(reference, index, text);
    result.start = start.clone();
    result.end = end?.clone();
    return result;
  }

  @override
  DateTime date() {
    return start.date();
  }

  @override
  Set<String> tags() {
    final combinedTags = start.tags().toSet();
    if (end != null) {
      for (final tag in end!.tags()) {
        combinedTags.add(tag);
      }
    }
    return combinedTags;
  }

  @override
  toString() {
    final tags = this.tags().toList();
    return '''ParsingResult {index: $index, text: '$text', tags: ${jsonEncode(tags)}, date: ${date()}}''';
  }
}
