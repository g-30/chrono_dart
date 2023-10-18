/*
    Enforce 'forwardDate' option to on the results. When there are missing component,
    e.g. "March 12-13 (without year)" or "Thursday", the refiner will try to adjust the result
    into the future instead of the past.
*/

import 'package:day/day.dart' as dayjs;
import '../../chrono.dart' show ParsingContext, Refiner;
import '../../types.dart' show Component;
import '../../results.dart' show ParsingResult;
import '../../utils/day.dart' show implySimilarDate;

extension DayWeekdayWriter on dayjs.Day {
  /// Gets or sets the weekday
  dayjs.Day setWeekday(int day) {
    final d = clone();
    d.setValue('weekday', day);
    d.finished();
    return d;
  }
}

class ForwardDateRefiner implements Refiner {
  @override
  List<ParsingResult> refine(
      ParsingContext context, List<ParsingResult> results) {
    if (context.option.forwardDate == null) {
      return results;
    }

    for (final result in results) {
      var refMoment = dayjs.Day.fromDateTime(context.reference.instant);

      if (result.start.isOnlyTime() &&
          refMoment.isAfter(result.start.dayjs())) {
        refMoment = refMoment.add(1, 'd')!;
        implySimilarDate(result.start, refMoment);
        if (result.end != null && result.end!.isOnlyTime()) {
          implySimilarDate(result.end!, refMoment);
          if (result.start.dayjs().isAfter(result.end!.dayjs())) {
            refMoment = refMoment.add(1, 'd')!;
            implySimilarDate(result.end!, refMoment);
          }
        }
      }

      if (result.start.isOnlyWeekdayComponent() &&
          refMoment.isAfter(result.start.dayjs())) {
        if (refMoment.weekday() >= result.start.get(Component.weekday)!) {
          refMoment =
              refMoment.setWeekday(result.start.get(Component.weekday)! + 7);
        } else {
          refMoment =
              refMoment.setWeekday(result.start.get(Component.weekday)!);
        }

        result.start.imply(Component.day, refMoment.date());
        result.start.imply(Component.month, refMoment.month());
        result.start.imply(Component.year, refMoment.year());
        context.debug(() {
          print("Forward weekly adjusted for $result (${result.start})");
        });

        if (result.end != null && result.end!.isOnlyWeekdayComponent()) {
          // Adjust date to the coming week
          if (refMoment.weekday() > result.end!.get(Component.weekday)!) {
            refMoment =
                refMoment.setWeekday(result.end!.get(Component.weekday)! + 7);
          } else {
            refMoment =
                refMoment.setWeekday(result.end!.get(Component.weekday)!);
          }

          result.end!.imply(Component.day, refMoment.date());
          result.end!.imply(Component.month, refMoment.month());
          result.end!.imply(Component.year, refMoment.year());
          context.debug(() {
            print("Forward weekly adjusted for $result (${result.end})");
          });
        }
      }

      // In case where we know the month, but not which year (e.g. "in December", "25th December"),
      // try move to another year
      if (result.start.isDateWithUnknownYear() &&
          refMoment.isAfter(result.start.dayjs())) {
        for (int i = 0; i < 3 && refMoment.isAfter(result.start.dayjs()); i++) {
          result.start
              .imply(Component.year, result.start.get(Component.year)! + 1);
          context.debug(() {
            print("Forward yearly adjusted for $result (${result.start})");
          });

          if (result.end != null && !result.end!.isCertain(Component.year)) {
            result.end!
                .imply(Component.year, result.end!.get(Component.year)! + 1);
            context.debug(() {
              print("Forward yearly adjusted for $result (${result.end})");
            });
          }
        }
      }
    }

    return results;
  }
}
