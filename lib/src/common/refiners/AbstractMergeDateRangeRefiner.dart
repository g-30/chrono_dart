import 'dart:math' show min;
import '../../results.dart' show ParsingResult;
import '../../types.dart' show Component;
import '../abstract_refiners.dart' show MergingRefiner;

abstract class AbstractMergeDateRangeRefiner extends MergingRefiner {
  RegExp patternBetween();

  @override
  bool shouldMergeResults(textBetween, currentResult, nextResult, context) {
    return currentResult.end == null &&
        nextResult.end == null &&
        patternBetween().hasMatch(textBetween);
  }

  @override
  // ignore: avoid_renaming_method_parameters
  ParsingResult mergeResults(textBetween, fromResult, toResult, context) {
    if (!fromResult.start.isOnlyWeekdayComponent() &&
        !toResult.start.isOnlyWeekdayComponent()) {
      toResult.start.getCertainComponents().forEach((key) {
        if (!fromResult.start.isCertain(key)) {
          fromResult.start.imply(key, toResult.start.get(key)!);
        }
      });

      fromResult.start.getCertainComponents().forEach((key) {
        if (!toResult.start.isCertain(key)) {
          toResult.start.imply(key, fromResult.start.get(key)!);
        }
      });
    }

    if (fromResult.start.date().millisecondsSinceEpoch >
        toResult.start.date().millisecondsSinceEpoch) {
      var fromMoment = fromResult.start.dayjs();
      var toMoment = toResult.start.dayjs();
      if (toResult.start.isOnlyWeekdayComponent() &&
          toMoment.add(7, "days")!.isAfter(fromMoment)) {
        toMoment = toMoment.add(7, "days")!;
        toResult.start.imply(Component.day, toMoment.date());
        toResult.start.imply(Component.month, toMoment.month() + 1);
        toResult.start.imply(Component.year, toMoment.year());
      } else if (fromResult.start.isOnlyWeekdayComponent() &&
          fromMoment.add(-7, "days")!.isBefore(toMoment)) {
        fromMoment = fromMoment.add(-7, "days")!;
        fromResult.start.imply(Component.day, fromMoment.date());
        fromResult.start.imply(Component.month, fromMoment.month() + 1);
        fromResult.start.imply(Component.year, fromMoment.year());
      } else if (toResult.start.isDateWithUnknownYear() &&
          toMoment.add(1, "years")!.isAfter(fromMoment)) {
        toMoment = toMoment.add(1, "years")!;
        toResult.start.imply(Component.year, toMoment.year());
      } else if (fromResult.start.isDateWithUnknownYear() &&
          fromMoment.add(-1, "years")!.isBefore(toMoment)) {
        fromMoment = fromMoment.add(-1, "years")!;
        fromResult.start.imply(Component.year, fromMoment.year());
      } else {
        [toResult, fromResult] = [fromResult, toResult];
      }
    }

    final result = fromResult.clone();
    result.start = fromResult.start;
    result.end = toResult.start;
    result.index = min(fromResult.index, toResult.index);
    if (fromResult.index < toResult.index) {
      result.text = fromResult.text + textBetween + toResult.text;
    } else {
      result.text = toResult.text + textBetween + fromResult.text;
    }

    return result;
  }
}
