import 'package:day/day.dart' as dayjs;
import '../../../chrono.dart' show ParsingContext;
import '../../../types.dart' show RegExpChronoMatch, Component;
import '../../../common/parsers/AbstractParserWithWordBoundary.dart';
import '../../../utils/day.dart' show assignSimilarDate;
import '../../../common/casual_references.dart' as references;

final _pattern = RegExp(
    r'(now|today|tonight|tomorrow|tmr|tmrw|yesterday|last\s*night)(?=\W|$)',
    caseSensitive: false);

class ENCasualDateParser extends AbstractParserWithWordBoundaryChecking {
  @override
  RegExp innerPattern(ParsingContext context) {
    return _pattern;
  }

  /// @returns ParsingComponents | ParsingResult
  @override
  innerExtract(ParsingContext context, RegExpChronoMatch match) {
    var targetDate = dayjs.Day.fromDateTime(context.reference.instant);
    final lowerText = match[0]!.toLowerCase();
    var component = context.createParsingComponents();

    switch (lowerText) {
      case "now":
        component = references.now(context.reference);
        break;

      case "today":
        component = references.today(context.reference);
        break;

      case "yesterday":
        component = references.yesterday(context.reference);
        break;

      case "tomorrow":
      case "tmr":
      case "tmrw":
        component = references.tomorrow(context.reference);
        break;

      case "tonight":
        component = references.tonight(context.reference);
        break;

      default:
        if (RegExp(r'last\s*night').hasMatch(lowerText)) {
          if (targetDate.hour() > 6) {
            targetDate = targetDate.add(-1, 'd')!;
          }

          assignSimilarDate(component, targetDate);
          component.imply(Component.hour, 0);
        }
        break;
    }
    component.addTag("parser/ENCasualDateParser");
    return component;
  }
}
