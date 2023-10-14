import "../../../types.dart" show Component;
import '../../../common/abstract_refiners.dart' show MergingRefiner;
import "../../../results.dart"
    show ParsingComponents, ParsingResult, ReferenceWithTimezone;
import "../constants.dart" show parseTimeUnits;
import "../../../utils/timeunits.dart" show reverseTimeUnits;

bool hasImpliedEarlierReferenceDate(ParsingResult result) {
  return RegExp(r'\s+(before|from)$').hasMatch(result.text);
}

bool hasImpliedLaterReferenceDate(ParsingResult result) {
  return RegExp(r'\s+(after|since)$', caseSensitive: false)
      .hasMatch(result.text);
}

/// Merges an absolute date with a relative date.
/// - 2 weeks before 2020-02-13
/// - 2 days after next Friday
class ENMergeRelativeDateRefiner extends MergingRefiner {
  RegExp patternBetween() {
    return RegExp(r'^\s*$', caseSensitive: false);
  }

  @override
  bool shouldMergeResults(String textBetween, ParsingResult currentResult,
      ParsingResult nextResult, context) {
    // Dates need to be next to each other to get merged
    if (!patternBetween().hasMatch(textBetween)) {
      return false;
    }

    // Check if any relative tokens were swallowed by the first date.
    // E.g. [<relative_date1> from] [<date2>]
    if (!hasImpliedEarlierReferenceDate(currentResult) &&
        !hasImpliedLaterReferenceDate(currentResult)) {
      return false;
    }

    // make sure that <date2> implies an absolute date
    return nextResult.start.get(Component.day) != null &&
        nextResult.start.get(Component.month) != null &&
        nextResult.start.get(Component.year) != null;
  }

  @override
  ParsingResult mergeResults(String textBetween, ParsingResult currentResult,
      ParsingResult nextResult, context) {
    var timeUnits = parseTimeUnits(currentResult.text);
    if (hasImpliedEarlierReferenceDate(currentResult)) {
      timeUnits = reverseTimeUnits(timeUnits);
    }

    final components = ParsingComponents.createRelativeFromReference(
        ReferenceWithTimezone(nextResult.start.date()), timeUnits);

    return ParsingResult(nextResult.reference, currentResult.index,
        "${currentResult.text}$textBetween${nextResult.text}", components);
  }
}
