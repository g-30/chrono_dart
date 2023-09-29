import '../types.dart' show Component, Meridiem;
import '../results.dart' show ParsingComponents, ParsingResult;
import '../utils/day.dart' show assignSimilarDate, implySimilarDate;

ParsingResult mergeDateTimeResult(
    ParsingResult dateResult, ParsingResult timeResult) {
  final result = dateResult.clone();
  final beginDate = dateResult.start;
  final beginTime = timeResult.start;

  result.start = mergeDateTimeComponent(beginDate, beginTime);
  if (dateResult.end != null || timeResult.end != null) {
    final endDate = dateResult.end ?? dateResult.start;
    final endTime = timeResult.end ?? timeResult.start;
    final endDateTime = mergeDateTimeComponent(endDate, endTime);

    if (dateResult.end == null &&
        endDateTime.date().millisecondsSinceEpoch < result.start.date().millisecondsSinceEpoch) {
      // For example,  "Tuesday 9pm - 1am" the ending should actually be 1am on the next day.
      // We need to add to ending by another day.
      final nextDayJs = endDateTime.dayjs().add(1, "day")!;
      if (endDateTime.isCertain(Component.day)) {
        assignSimilarDate(endDateTime, nextDayJs);
      } else {
        implySimilarDate(endDateTime, nextDayJs);
      }
    }

    result.end = endDateTime;
  }

  return result;
}

ParsingComponents mergeDateTimeComponent(
    ParsingComponents dateComponent, ParsingComponents timeComponent) {
  final dateTimeComponent = dateComponent.clone();

  if (timeComponent.isCertain(Component.hour)) {
    dateTimeComponent.assign(
        Component.hour, timeComponent.get(Component.hour)!);
    dateTimeComponent.assign(
        Component.minute, timeComponent.get(Component.minute)!);

    if (timeComponent.isCertain(Component.second)) {
      dateTimeComponent.assign(
          Component.second, timeComponent.get(Component.second)!);

      if (timeComponent.isCertain(Component.millisecond)) {
        dateTimeComponent.assign(
            Component.millisecond, timeComponent.get(Component.millisecond)!);
      } else {
        dateTimeComponent.imply(
            Component.millisecond, timeComponent.get(Component.millisecond)!);
      }
    } else {
      dateTimeComponent.imply(
          Component.second, timeComponent.get(Component.second)!);
      dateTimeComponent.imply(
          Component.millisecond, timeComponent.get(Component.millisecond)!);
    }
  } else {
    dateTimeComponent.imply(Component.hour, timeComponent.get(Component.hour)!);
    dateTimeComponent.imply(
        Component.minute, timeComponent.get(Component.minute)!);
    dateTimeComponent.imply(
        Component.second, timeComponent.get(Component.second)!);
    dateTimeComponent.imply(
        Component.millisecond, timeComponent.get(Component.millisecond)!);
  }

  if (timeComponent.isCertain(Component.timezoneOffset)) {
    dateTimeComponent.assign(
        Component.timezoneOffset, timeComponent.get(Component.timezoneOffset)!);
  }

  if (timeComponent.isCertain(Component.meridiem)) {
    dateTimeComponent.assign(
        Component.meridiem, timeComponent.get(Component.meridiem)!);
  } else if (timeComponent.get(Component.meridiem) != null &&
      dateTimeComponent.get(Component.meridiem) == null) {
    dateTimeComponent.imply(
        Component.meridiem, timeComponent.get(Component.meridiem)!);
  }

  if (dateTimeComponent.get(Component.meridiem) == Meridiem.PM.id &&
      dateTimeComponent.get(Component.hour)! < 12) {
    if (timeComponent.isCertain(Component.hour)) {
      dateTimeComponent.assign(
          Component.hour, dateTimeComponent.get(Component.hour)! + 12);
    } else {
      dateTimeComponent.imply(
          Component.hour, dateTimeComponent.get(Component.hour)! + 12);
    }
  }

  dateTimeComponent.addTags(dateComponent.tags());
  dateTimeComponent.addTags(timeComponent.tags());
  return dateTimeComponent;
}
