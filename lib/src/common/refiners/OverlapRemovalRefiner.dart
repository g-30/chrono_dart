import '../../chrono.dart' show ParsingContext, Refiner;
import '../../results.dart' show ParsingResult;

class OverlapRemovalRefiner implements Refiner {
  @override
  List<ParsingResult> refine(
      ParsingContext context, List<ParsingResult> results) {
    if (results.length < 2) {
      return results;
    }

    final List<ParsingResult> filteredResults = [];

    ParsingResult? prevResult = results[0];
    for (int i = 1; i < results.length; i++) {
      final result = results[i];

      // If overlap, compare the length and discard the shorter one
      if (result.index < prevResult!.index + prevResult.text.length) {
        if (result.text.length > prevResult.text.length) {
          prevResult = result;
        }
      } else {
        filteredResults.add(prevResult);
        prevResult = result;
      }
    }

    // The last one
    if (prevResult != null) {
      filteredResults.add(prevResult);
    }

    return filteredResults;
  }
}
