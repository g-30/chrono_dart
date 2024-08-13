import '../results.dart' show ParsingComponents;
import '../types.dart' show Component;

typedef TimeUnits = Map<String, num>;

TimeUnits reverseTimeUnits(TimeUnits timeUnits) {
  final reversed = <String, num>{};
  for (final key in timeUnits.keys) {
    reversed[key] = -timeUnits[key]!;
  }

  return reversed;
}

ParsingComponents addImpliedTimeUnits(
    ParsingComponents components, TimeUnits timeUnits) {
  final output = components.clone();

  var date = components.dayjs();
  for (final key in timeUnits.keys) {
    /// TODO: WARNING: forces doubles to be int. Needs research
    date = date.add(timeUnits[key]!.toInt(), key)!;
  }

  if (timeUnits.containsKey("day") ||
      timeUnits.containsKey("d") ||
      timeUnits.containsKey("week") ||
      timeUnits.containsKey("month") ||
      timeUnits.containsKey("year")) {
    output.imply(Component.day, date.date());
    output.imply(Component.month, date.month());
    output.imply(Component.year, date.year());
  }

  if (timeUnits.containsKey("second") ||
      timeUnits.containsKey("minute") ||
      timeUnits.containsKey("hour")) {
    output.imply(Component.second, date.second());
    output.imply(Component.minute, date.minute());
    output.imply(Component.hour, date.hour());
  }

  return output;
}
