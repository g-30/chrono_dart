import '../../../chrono.dart' show ParsingContext;
import '../../../results.dart' show ParsingComponents;
import '../../../types.dart' show Meridiem, Component;
import '../../../common/parsers/AbstractTimeExpressionParser.dart'
    show AbstractTimeExpressionParser;

class ENTimeExpressionParser extends AbstractTimeExpressionParser {
  ENTimeExpressionParser(strictMode) : super(strictMode);

  @override
  String followingPhase() {
    return "\\s*(?:\\-|\\–|\\~|\\〜|to|until|through|till|\\?)\\s*";
  }

  @override
  String primaryPrefix() {
    return "(?:(?:at|from)\\s*)??";
  }

  @override
  String primarySuffix() {
    return "(?:\\s*(?:o\\W*clock|at\\s*night|in\\s*the\\s*(?:morning|afternoon)))?(?!/)(?=\\W|\$)";
  }

  @override
  ParsingComponents? extractPrimaryTimeComponents(
      ParsingContext context, RegExpMatch match,
      [bool strict = false]) {
    final components =
        super.extractPrimaryTimeComponents(context, match, strict);
    if (components == null) {
      return components;
    }

    if (match[0]!.endsWith("night")) {
      final hour = components.get(Component.hour)!;
      if (hour >= 6 && hour < 12) {
        components.assign(Component.hour, components.get(Component.hour)! + 12);
        components.assign(Component.meridiem, Meridiem.PM.id);
      } else if (hour < 6) {
        components.assign(Component.meridiem, Meridiem.AM.id);
      }
    }

    if (match[0]!.endsWith("afternoon")) {
      components.assign(Component.meridiem, Meridiem.PM.id);
      final hour = components.get(Component.hour)!;
      if (hour >= 0 && hour <= 6) {
        components.assign(Component.hour, components.get(Component.hour)! + 12);
      }
    }

    if (match[0]!.endsWith("morning")) {
      components.assign(Component.meridiem, Meridiem.AM.id);
      final hour = components.get(Component.hour)!;
      if (hour < 12) {
        components.assign(Component.hour, components.get(Component.hour)!);
      }
    }

    return components.addTag("parser/ENTimeExpressionParser");
  }
}
