import '../abstractRefiners.dart' show Filter;
import '../../results.dart' show ParsingResult;
import '../../types.dart' show Component;

class UnlikelyFormatFilter extends Filter {

  final bool _strictMode;

  UnlikelyFormatFilter([ bool strictMode = false ]):
    _strictMode = strictMode,
    super();

  @override
  bool isValid(context, ParsingResult result) {
    if (RegExp(r'^\d*(\.\d*)?$').hasMatch(result.text.replaceFirst(" ", ""))) {
      context.debug(() => {
          print("Removing unlikely result '${result.text}'")
      });

      return false;
    }

    if (!result.start.isValidDate()) {
      context.debug(() => {
          print("Removing invalid result: $result (${result.start})")
      });

      return false;
    }

    if (result.end != null && !result.end!.isValidDate()) {
      context.debug(() => {
          print("Removing invalid result: $result (${result.end})")
      });

      return false;
    }

    if (_strictMode) {
      return isStrictModeValid(context, result);
    }

    return true;
  }

  bool isStrictModeValid(context, ParsingResult result) {
    if (result.start.isOnlyWeekdayComponent()) {
      context.debug(() => {
          print("(Strict) Removing weekday only component: $result (${result.end})")
      });

      return false;
    }

    if (result.start.isOnlyTime() && (!result.start.isCertain(Component.hour) || !result.start.isCertain(Component.minute))) {
      context.debug(() => {
          print("(Strict) Removing uncertain time component: $result (${result.end})")
      });

      return false;
    }

    return true;
  }
}
