import 'package:test/test.dart';
import 'package:chrono_dart/src/debugging.dart' show BufferedDebugHandler;
import 'package:chrono_dart/chrono_dart.dart'
    show ChronoInstance, ParsedResult, ParsingOption, ParsingReference;

typedef ChronoLike = ChronoInstance;
typedef CheckResult = void Function(ParsedResult p, String text);

void testSingleCase(
  ChronoLike chrono,
  String text, [
  /// [ ParsingReference | Date | CheckResult ]
  refDateOrCheckResult,

  /// ParsingOption | CheckResult,
  optionOrCheckResult,
  CheckResult? checkResult,
]) {
  var _refDateOrCheckResult = refDateOrCheckResult;
  var _optionOrCheckResult = optionOrCheckResult;
  var _checkResult = checkResult;
  if (_checkResult == null && _optionOrCheckResult is CheckResult) {
    _checkResult = _optionOrCheckResult;
    _optionOrCheckResult = null;
  }

  if (_optionOrCheckResult == null && _refDateOrCheckResult is CheckResult) {
    _checkResult = _refDateOrCheckResult;
    _refDateOrCheckResult = null;
  }

  final debugHandler = BufferedDebugHandler();
  _optionOrCheckResult = _optionOrCheckResult ?? ParsingOption();
  if (_optionOrCheckResult is ParsingOption) {
    _optionOrCheckResult.debug = debugHandler;
  }

  try {
    final results = chrono.parse(
        text,
        _refDateOrCheckResult is DateTime ||
                _refDateOrCheckResult is ParsingReference
            ? _refDateOrCheckResult
            : null,
        _optionOrCheckResult is ParsingOption ? _optionOrCheckResult : null);
    expect(results, toBeSingleOnText(text));
    if (_checkResult != null) {
      _checkResult(results[0], text);
    }
  } catch (e) {
    debugHandler.executeBufferedBlocks();
    rethrow;
  }
}

void testWithExpectedDate(
    ChronoLike chrono, String text, DateTime expectedDate) {
  testSingleCase(chrono, text, (result) {
    expect(result.start, toBeDate(expectedDate));
  });
}

void testUnexpectedResult(ChronoLike chrono, String text,
    [DateTime? refDate, ParsingOption? options]) {
  final debugHandler = BufferedDebugHandler();
  options ??= ParsingOption();
  options.debug = debugHandler;

  try {
    final results = chrono.parse(text, refDate, options);
    expect(results, hasLength(0));
  } catch (e) {
    debugHandler.executeBufferedBlocks();
    rethrow;
  }
}

int measureMilliSec(Function block) {
  final startTime = DateTime.now().millisecondsSinceEpoch;
  block();
  final endTime = DateTime.now().millisecondsSinceEpoch;
  return endTime - startTime;
}

Matcher toBeDate(DateTime matcher) => wrapMatcher((Object? item) {
  if (item is DateTime) {
    if (item.millisecondsSinceEpoch == matcher.millisecondsSinceEpoch) {
      return true;
    }
    throw 'Actual: $item, expected: $matcher';
  }
  if ((item as dynamic).date is Function) {
    final date = (item as dynamic).date() as DateTime;
    if (date.millisecondsSinceEpoch == matcher.millisecondsSinceEpoch) {
      return true;
    }
    throw 'Actual: $date, expected: $matcher';
  }
  throw 'Actual is not a date object';
});

Matcher toBeSingleOnText(Object? matcher) =>
    _SingleOnText(wrapMatcher(matcher));

class _SingleOnText extends Matcher {
  final Matcher _matcher;
  _SingleOnText(this._matcher);

  @override
  bool matches(Object? item, Map matchState) {
    try {
      final length = (item as dynamic).length;
      return length == 1;
    } catch (e) {
      return false;
    }
  }

  @override
  Description describe(Description description) =>
      description.add("Got single result ").addDescriptionOf(_matcher);

  @override
  Description describeMismatch(Object? item, Description mismatchDescription,
      Map matchState, bool verbose) {
    try {
      final length = (item as dynamic).length;
      return mismatchDescription
          .add('Got ')
          .addDescriptionOf(length)
          .add(' results from ')
          .addDescriptionOf(item);
    } catch (e) {
      return mismatchDescription.add('has no length property');
    }
  }
}
