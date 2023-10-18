import 'package:day/day.dart' as dayjs;
import '../results.dart' show ParsingComponents;
import '../types.dart' show Meridiem, Component;

void assignTheNextDay(ParsingComponents component, dayjs.Day targetDayJs) {
  targetDayJs = targetDayJs.add(1, 'd')!;
  assignSimilarDate(component, targetDayJs);
  implySimilarTime(component, targetDayJs);
}

void implyTheNextDay(ParsingComponents component, dayjs.Day targetDayJs) {
  targetDayJs = targetDayJs.add(1, 'd')!;
  implySimilarDate(component, targetDayJs);
  implySimilarTime(component, targetDayJs);
}

void assignSimilarDate(ParsingComponents component, dayjs.Day targetDayJs) {
  component.assign(Component.day, targetDayJs.date());
  component.assign(Component.month, targetDayJs.month());
  component.assign(Component.year, targetDayJs.year());
}

void assignSimilarTime(ParsingComponents component, dayjs.Day targetDayJs) {
  component.assign(Component.hour, targetDayJs.hour());
  component.assign(Component.minute, targetDayJs.minute());
  component.assign(Component.second, targetDayJs.second());
  component.assign(Component.millisecond, targetDayJs.millisecond());
  if ((component.get(Component.day) ?? 12) < 12) {
    component.assign(Component.meridiem, Meridiem.AM.id);
  } else {
    component.assign(Component.meridiem, Meridiem.PM.id);
  }
}

void implySimilarDate(ParsingComponents component, dayjs.Day targetDayJs) {
  component.imply(Component.day, targetDayJs.date());
  component.imply(Component.month, targetDayJs.month());
  component.imply(Component.year, targetDayJs.year());
}

void implySimilarTime(ParsingComponents component, dayjs.Day targetDayJs) {
  component.imply(Component.hour, targetDayJs.hour());
  component.imply(Component.minute, targetDayJs.minute());
  component.imply(Component.second, targetDayJs.second());
  component.imply(Component.millisecond, targetDayJs.millisecond());
}
