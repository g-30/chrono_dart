import '../results.dart' show ParsingComponents, ReferenceWithTimezone;
import 'package:day/day.dart' as dayjs;
import '../utils/day.dart'
    show
        assignSimilarDate,
        assignSimilarTime,
        implySimilarTime,
        implyTheNextDay;
import '../types.dart' show Meridiem, Component;

ParsingComponents now(ReferenceWithTimezone reference) {
  final targetDate = dayjs.Day.fromDateTime(reference.instant);
  final component = ParsingComponents(reference, {});
  assignSimilarDate(component, targetDate);
  assignSimilarTime(component, targetDate);
  if (reference.timezoneOffset != null) {
    component.assign(
        Component.timezoneOffset, targetDate.timeZoneOffset.inMinutes);
  }
  component.addTag("casualReference/now");
  return component;
}

ParsingComponents today(ReferenceWithTimezone reference) {
  final targetDate = dayjs.Day.fromDateTime(reference.instant);
  final component = ParsingComponents(reference, {});
  assignSimilarDate(component, targetDate);
  implySimilarTime(component, targetDate);
  component.addTag("casualReference/today");
  return component;
}

/// The previous day. Imply the same time.
ParsingComponents yesterday(ReferenceWithTimezone reference) {
  return theDayBefore(reference, 1).addTag("casualReference/yesterday");
}

ParsingComponents theDayBefore(ReferenceWithTimezone reference, int numDay) {
  return theDayAfter(reference, -numDay);
}

/// The following day with dayjs.assignTheNextDay()
ParsingComponents tomorrow(ReferenceWithTimezone reference) {
  return theDayAfter(reference, 1).addTag("casualReference/tomorrow");
}

ParsingComponents theDayAfter(ReferenceWithTimezone reference, int nDays) {
  var targetDate = dayjs.Day.fromDateTime(reference.instant);
  final component = ParsingComponents(reference, {});
  targetDate = targetDate.add(nDays, 'd')!;
  assignSimilarDate(component, targetDate);
  implySimilarTime(component, targetDate);
  return component;
}

ParsingComponents tonight(ReferenceWithTimezone reference,
    [int implyHour = 22]) {
  final targetDate = dayjs.Day.fromDateTime(reference.instant);
  final component = ParsingComponents(reference, {});
  assignSimilarDate(component, targetDate);
  component.imply(Component.hour, implyHour);
  component.imply(Component.meridiem, Meridiem.PM.id);
  component.addTag("casualReference/tonight");
  return component;
}

ParsingComponents lastNight(ReferenceWithTimezone reference,
    [int implyHour = 0]) {
  var targetDate = dayjs.Day.fromDateTime(reference.instant);
  final component = ParsingComponents(reference, {});
  if (targetDate.hour() < 6) {
    targetDate = targetDate.add(-1, 'd')!;
  }
  assignSimilarDate(component, targetDate);
  component.imply(Component.hour, implyHour);
  return component;
}

ParsingComponents evening(ReferenceWithTimezone reference,
    [int implyHour = 20]) {
  final component = ParsingComponents(reference, {});
  component.imply(Component.meridiem, Meridiem.PM.id);
  component.imply(Component.hour, implyHour);
  component.addTag("casualReference/evening");
  return component;
}

ParsingComponents yesterdayEvening(ReferenceWithTimezone reference,
    [int implyHour = 20]) {
  var targetDate = dayjs.Day.fromDateTime(reference.instant);
  final component = ParsingComponents(reference, {});
  targetDate = targetDate.add(-1, 'd')!;
  assignSimilarDate(component, targetDate);
  component.imply(Component.hour, implyHour);
  component.imply(Component.meridiem, Meridiem.PM.id);
  component.addTag("casualReference/yesterday");
  component.addTag("casualReference/evening");
  return component;
}

ParsingComponents midnight(ReferenceWithTimezone reference) {
  final component = ParsingComponents(reference, {});
  final targetDate = dayjs.Day.fromDateTime(reference.instant);
  if (targetDate.hour() > 2) {
    // Unless it's very early morning (0~2AM), we assume the midnight is the coming midnight.
    // Thus, increasing the day by 1.
    implyTheNextDay(component, targetDate);
  }
  component.assign(Component.hour, 0);
  component.imply(Component.minute, 0);
  component.imply(Component.second, 0);
  component.imply(Component.millisecond, 0);
  component.addTag("casualReference/midnight");
  return component;
}

ParsingComponents morning(ReferenceWithTimezone reference,
    [int implyHour = 6]) {
  final component = ParsingComponents(reference, {});
  component.imply(Component.meridiem, Meridiem.AM.id);
  component.imply(Component.hour, implyHour);
  component.imply(Component.minute, 0);
  component.imply(Component.second, 0);
  component.imply(Component.millisecond, 0);
  component.addTag("casualReference/morning");
  return component;
}

ParsingComponents afternoon(ReferenceWithTimezone reference,
    [int implyHour = 15]) {
  final component = ParsingComponents(reference, {});
  component.imply(Component.meridiem, Meridiem.PM.id);
  component.imply(Component.hour, implyHour);
  component.imply(Component.minute, 0);
  component.imply(Component.second, 0);
  component.imply(Component.millisecond, 0);
  component.addTag("casualReference/afternoon");
  return component;
}

ParsingComponents noon(ReferenceWithTimezone reference) {
  final component = ParsingComponents(reference, {});
  component.imply(Component.meridiem, Meridiem.AM.id);
  component.imply(Component.hour, 12);
  component.imply(Component.minute, 0);
  component.imply(Component.second, 0);
  component.imply(Component.millisecond, 0);
  component.addTag("casualReference/noon");
  return component;
}
