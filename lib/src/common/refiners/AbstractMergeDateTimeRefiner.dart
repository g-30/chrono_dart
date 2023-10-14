import '../../results.dart' show ParsingResult;
import '../abstract_refiners.dart' show MergingRefiner;
import '../../calculation/mergingCalculation.dart' show mergeDateTimeResult;

abstract class AbstractMergeDateTimeRefiner extends MergingRefiner {
  RegExp patternBetween();

  @override
  bool shouldMergeResults(String textBetween, ParsingResult currentResult,
      ParsingResult nextResult, context) {
    return (((currentResult.start.isOnlyDate() &&
                nextResult.start.isOnlyTime()) ||
            (nextResult.start.isOnlyDate() &&
                currentResult.start.isOnlyTime())) &&
        patternBetween().hasMatch(textBetween));
  }

  @override
  ParsingResult mergeResults(String textBetween, ParsingResult currentResult,
      ParsingResult nextResult, context) {
    final result = currentResult.start.isOnlyDate()
        ? mergeDateTimeResult(currentResult, nextResult)
        : mergeDateTimeResult(nextResult, currentResult);

    result.index = currentResult.index;
    result.text = currentResult.text + textBetween + nextResult.text;
    return result;
  }
}
