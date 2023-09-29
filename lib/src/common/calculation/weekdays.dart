import '../../types.dart' show Component, Weekday;
import '../../results.dart' show ParsingComponents, ReferenceWithTimezone;
import '../../utils/timeunits.dart' show addImpliedTimeUnits;

/// Returns the parsing components at the weekday (considering the modifier). The time and timezone is assume to be
/// similar to the reference.
/// @param reference
/// @param weekday
/// @param modifier "this", "next", "last" modifier word. If empty, returns the weekday closest to the `refDate`.
ParsingComponents createParsingComponentsAtWeekday(
    ReferenceWithTimezone reference, Weekday weekday,
    [String? modifier]) {
  final refDate = reference.getDateWithAdjustedTimezone();
  final daysToWeekday = getDaysToWeekday(refDate, weekday, modifier);

  var components = ParsingComponents(reference);
  components = addImpliedTimeUnits(components, {"d": daysToWeekday});
  components.assign(Component.weekday, weekday.id);

  return components;
}

/// Returns number of days from refDate to the weekday. The refDate date and timezone information is used.
/// @param refDate
/// @param weekday
/// @param modifier "this", "next", "last" modifier word. If empty, returns the weekday closest to the `refDate`.
int getDaysToWeekday(DateTime refDate, Weekday weekday, [String? modifier]) {
  assert(modifier == null ||
      modifier == "this" ||
      modifier == "next" ||
      modifier == "last");
  final refWeekday = Weekday.weekById(refDate.weekday);
  switch (modifier) {
    case "this":
      return getDaysForwardToWeekday(refDate, weekday);
    case "last":
      return getBackwardDaysToWeekday(refDate, weekday);
    case "next":
      // From Sunday, the next Sunday is 7 days later.
      // Otherwise, next Mon is 1 days later, next Tues is 2 days later, and so on..., (return enum value)
      if (refWeekday == Weekday.SUNDAY) {
        return weekday == Weekday.SUNDAY ? 7 : weekday.id;
      }
      // From Saturday, the next Saturday is 7 days later, the next Sunday is 8-days later.
      // Otherwise, next Mon is (1 + 1) days later, next Tues is (1 + 2) days later, and so on...,
      // (return, 2 + [enum value] days)
      if (refWeekday == Weekday.SATURDAY) {
        if (weekday == Weekday.SATURDAY) return 7;
        if (weekday == Weekday.SUNDAY) return 8;
        return 1 + weekday.id;
      }
      // From weekdays, next Mon is the following week's Mon, next Tues the following week's Tues, and so on...
      // If the week's weekday already passed (weekday < refWeekday), we simply count forward to next week
      // (similar to 'this'). Otherwise, count forward to this week, then add another 7 days.
      if (weekday.id < refWeekday.id && weekday != Weekday.SUNDAY) {
        return getDaysForwardToWeekday(refDate, weekday);
      } else {
        return getDaysForwardToWeekday(refDate, weekday) + 7;
      }
  }
  return getDaysToWeekdayClosest(refDate, weekday);
}

int getDaysToWeekdayClosest(DateTime refDate, Weekday weekday) {
  final backward = getBackwardDaysToWeekday(refDate, weekday);
  final forward = getDaysForwardToWeekday(refDate, weekday);

  return forward < -backward ? forward : backward;
}

int getDaysForwardToWeekday(DateTime refDate, Weekday weekday) {
  final refWeekday = Weekday.weekById(refDate.weekday);
  var forwardCount = weekday.id - refWeekday.id;
  if (forwardCount < 0) {
    forwardCount += 7;
  }
  return forwardCount;
}

int getBackwardDaysToWeekday(DateTime refDate, Weekday weekday) {
  final refWeekday = Weekday.weekById(refDate.weekday);
  var backwardCount = weekday.id - refWeekday.id;
  if (backwardCount >= 0) {
    backwardCount -= 7;
  }
  return backwardCount;
}
