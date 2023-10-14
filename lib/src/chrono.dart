import './results.dart'
    show ReferenceWithTimezone, ParsingComponents, ParsingResult;
import './types.dart'
    show
        Component,
        ParsedResult,
        ParsingOption,
        ParsingReference,
        RegExpChronoMatch;
import './debugging.dart' show AsyncDebugBlock, DebugHandler;
import './locales/en/configuration.dart';

/// Chrono configuration.
/// It is simply an ordered list of parsers and refiners
class Configuration {
  final List<Parser> parsers;
  final List<Refiner> refiners;

  Configuration({required this.parsers, required this.refiners});
}

/// An abstraction for Chrono *Parser*.
///
/// Each parser should recognize and handle a certain date format.
/// Chrono uses multiple parses (and refiners) together for parsing the input.
///
/// The parser implementation must provide {@Link pattern | pattern()} for the date format.
///
/// The {@Link extract | extract()} method is called with the pattern's *match*.
/// The matching and extracting is controlled and adjusted to avoid for overlapping results.
abstract class Parser {
  RegExp pattern(ParsingContext context);

  /// @returns ParsingComponents | ParsingResult | { [c in Component]?: number } | null
  dynamic extract(ParsingContext context, RegExpChronoMatch match);
}

/// A abstraction for Chrono *Refiner*.
///
/// Each refiner takes the list of results (from parsers or other refiners) and returns another list of results.
/// Chrono applies each refiner in order and return the output from the last refiner.
abstract class Refiner {
  List<ParsingResult> refine(
      ParsingContext context, List<ParsingResult> results);
}

/// The Chrono object.
class ChronoInstance {
  List<Parser> parsers;
  List<Refiner> refiners;

  static const defaultConfig = ENDefaultConfiguration();

  ChronoInstance([Configuration? configuration])
      : parsers = (configuration ?? defaultConfig.createCasualConfiguration())
            .parsers,
        refiners = (configuration ?? defaultConfig.createCasualConfiguration())
            .refiners;

  /// Create a shallow copy of the Chrono object with the same configuration (`parsers` and `refiners`)
  ChronoInstance clone() {
    return ChronoInstance(Configuration(
      parsers: [...parsers],
      refiners: [...refiners],
    ));
  }

  /// A shortcut for calling {@Link parse | parse() } then transform the result into Dart's DateTime object
  /// @return DateTime object created from the first parse result
  DateTime? parseDate(String text,
      [dynamic referenceDate, ParsingOption? option]) {
    assert(referenceDate == null ||
        referenceDate is ParsingReference ||
        referenceDate is DateTime);
    final results = parse(text, referenceDate, option);
    return results.isNotEmpty ? results[0].start.date() : null;
  }

  List<ParsedResult> parse(String text,
      [dynamic referenceDate, ParsingOption? option]) {
    assert(referenceDate == null ||
        referenceDate is ParsingReference ||
        referenceDate is DateTime);

    final context = ParsingContext(text, referenceDate, option);

    List<ParsingResult> results = [];
    for (final parser in parsers) {
      final parsedResults = ChronoInstance._executeParser(context, parser);
      results = [...results, ...parsedResults];
    }

    results.sort((a, b) => a.index - b.index);

    for (final refiner in refiners) {
      results = refiner.refine(context, results);
    }

    return results;
  }

  static List<ParsingResult> _executeParser(
      ParsingContext context, Parser parser) {
    final List<ParsingResult> results = [];
    final pattern = parser.pattern(context);

    final originalText = context.text;
    var remainingText = context.text;
    var match =
        RegExpChronoMatch.matchOrNull(pattern.firstMatch(remainingText));

    while (match != null) {
      // Calculate match index on the full text;
      final index = match.index + originalText.length - remainingText.length;
      match.index = index;

      final result = parser.extract(context, match);
      if (result == null) {
        // If fails, move on by 1
        remainingText = match.index + 1 < originalText.length
            ? originalText.substring(match.index + 1)
            : '';
        match =
            RegExpChronoMatch.matchOrNull(pattern.firstMatch(remainingText));
        continue;
      }

      ParsingResult parsedResult;
      if (result is ParsingResult) {
        parsedResult = result;
      } else if (result is ParsingComponents) {
        parsedResult = context.createParsingResult(match.index, match[0]);
        parsedResult.start = result;
      } else {
        parsedResult =
            context.createParsingResult(match.index, match[0], result);
      }

      final parsedIndex = parsedResult.index;
      final parsedText = parsedResult.text;
      context.debug(() {
        print(
            "${parser.runtimeType} extracted (at index=$parsedIndex) '$parsedText'");
      });

      results.add(parsedResult);
      remainingText = originalText.substring(parsedIndex + parsedText.length);
      match = RegExpChronoMatch.matchOrNull(pattern.firstMatch(remainingText));
    }

    return results;
  }
}

class ParsingContext implements DebugHandler {
  final String text;
  final ParsingOption option;
  final ReferenceWithTimezone reference;

  @Deprecated('Use `reference.instant` instead.')
  late DateTime refDate;

  ParsingContext(this.text, dynamic irefDate, ParsingOption? option)
      : assert(irefDate == null ||
            irefDate is ParsingReference ||
            irefDate is DateTime),
        option = option ?? ParsingOption(),
        reference = ReferenceWithTimezone(irefDate) {
    // ignore: deprecated_member_use_from_same_package
    refDate = reference.instant;
  }

  ParsingComponents createParsingComponents([dynamic components]) {
    assert(components == null ||
        components is ParsingComponents ||
        components is Map<Component, num>);
    if (components is ParsingComponents) {
      return components;
    }

    /// TODO: WARNING: forcing double to int; needs research.
    final cmps = components == null
        ? null
        : Map<Component, num>.from(components)
            .map((key, val) => MapEntry(key, val.toInt()));

    return ParsingComponents(reference, cmps);
  }

  ParsingResult createParsingResult(
    int index,
    dynamic textOrEndIndex, [
    dynamic startComponents,
    dynamic endComponents,
  ]) {
    assert(textOrEndIndex is int || textOrEndIndex is String);
    assert(startComponents == null ||
        startComponents is ParsingComponents ||
        startComponents is Map<Component, num>);
    assert(endComponents == null ||
        endComponents is ParsingComponents ||
        endComponents is Map<Component, num>);
    final text = textOrEndIndex is String
        ? textOrEndIndex
        : this.text.substring(index, textOrEndIndex);

    final start = startComponents != null
        ? createParsingComponents(startComponents)
        : null;
    final end =
        endComponents != null ? createParsingComponents(endComponents) : null;

    return ParsingResult(reference, index, text, start, end);
  }

  @override
  void debug(AsyncDebugBlock block) {
    if (option.debug != null) {
      if (option.debug is Function) {
        option.debug(block);
      } else {
        final handler = option.debug as DebugHandler;
        handler.debug(block);
      }
    }
  }
}
