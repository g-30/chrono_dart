// ignore_for_file: prefer_interpolation_to_compose_strings

import '../../chrono.dart' show Parser, ParsingContext;
import '../../results.dart' show ParsingComponents, ParsingResult;
import '../../types.dart' show Meridiem, Component, RegExpChronoMatch;

// prettier-ignore
RegExp primaryTimePattern(
    String leftBoundary, String primaryPrefix, String primarySuffix,
    [String flags = '']) {
  return RegExp(
    leftBoundary +
        primaryPrefix +
        "(\\d{1,4})" +
        "(?:" +
        "(?:\\.|:|：)" +
        "(\\d{1,2})" +
        "(?:" +
        "(?::|：)" +
        "(\\d{2})" +
        "(?:\\.(\\d{1,6}))?" +
        ")?" +
        ")?" +
        "(?:\\s*(a\\.m\\.|p\\.m\\.|am?|pm?))?" +
        primarySuffix,
    caseSensitive: !flags.toLowerCase().contains('i'),
  );
}

// prettier-ignore
RegExp followingTimePatten(String followingPhase, String followingSuffix) {
  return RegExp(
    "^($followingPhase)" +
        "(\\d{1,4})" +
        "(?:" +
        "(?:\\.|\\:|\\：)" +
        "(\\d{1,2})" +
        "(?:" +
        "(?:\\.|\\:|\\：)" +
        "(\\d{1,2})(?:\\.(\\d{1,6}))?" +
        ")?" +
        ")?" +
        "(?:\\s*(a\\.m\\.|p\\.m\\.|am?|pm?))?" +
        followingSuffix,
    caseSensitive: false,
  );
}

const _HOUR_GROUP = 2;
const _MINUTE_GROUP = 3;
const _SECOND_GROUP = 4;
const _MILLI_SECOND_GROUP = 5;
const _AM_PM_HOUR_GROUP = 6;

abstract class AbstractTimeExpressionParser implements Parser {
  String primaryPrefix();
  String followingPhase();
  final bool strictMode;

  AbstractTimeExpressionParser([this.strictMode = false]);

  String patternFlags() {
    return "i";
  }

  String primaryPatternLeftBoundary() {
    return "(^|\\s|T|\\b)";
  }

  String primarySuffix() {
    return "(?!/)(?=\\W|\$)";
  }

  String followingSuffix() {
    return "(?!/)(?=\\W|\$)";
  }

  @override
  RegExp pattern(ParsingContext context) {
    return getPrimaryTimePatternThroughCache();
  }

  @override
  ParsingResult? extract(ParsingContext context, RegExpChronoMatch match) {
    final startComponents =
        extractPrimaryTimeComponents(context, match.original);
    if (startComponents == null) {
      match.index +=
          match[0]!.length; // Skip over potential overlapping pattern
      return null;
    }

    final index = match.index + match[1]!.length;
    final text = match[0]!.substring(match[1]!.length);
    final result = context.createParsingResult(index, text, startComponents);
    match.index += match[0]!.length; // Skip over potential overlapping pattern

    final remainingText = context.text.substring(match.index);
    final followingPattern = getFollowingTimePatternThroughCache();
    final followingMatch = followingPattern.firstMatch(remainingText);

    // Pattern "456-12", "2022-12" should not be time without proper context
    if (RegExp(r'^\d{3,4}').hasMatch(text) &&
        followingMatch != null &&
        RegExp(r'^\s*([+-])\s*\d{2,4}$').hasMatch(followingMatch[0]!)) {
      return null;
    }

    if (followingMatch == null ||
        // Pattern "YY.YY -XXXX" is more like timezone offset
        RegExp(r'^\s*([+-])\s*[0-9:]{3,5}$').hasMatch(followingMatch[0]!)) {
      /// TODO: WARNING: check regex; changed the 'official' version to also catch negative timezones; needs testing.
      return _checkAndReturnWithoutFollowingPattern(result);
    }

    result.end =
        extractFollowingTimeComponents(context, followingMatch, result);
    if (result.end != null) {
      result.text += followingMatch[0]!;
    }

    return _checkAndReturnWithFollowingPattern(result);
  }

  ParsingComponents? extractPrimaryTimeComponents(
      ParsingContext context, RegExpMatch match,
      [bool strict = false]) {
    final components = context.createParsingComponents();
    var minute = 0;
    Meridiem? meridiem;

    // ----- Hours
    var hour = int.parse(match[_HOUR_GROUP]!);
    if (hour > 100) {
      if (strictMode || match[_MINUTE_GROUP] != null) {
        return null;
      }

      minute = hour % 100;
      hour = (hour / 100).floor();
    }

    if (hour > 24) {
      return null;
    }

    // ----- Minutes
    if (match[_MINUTE_GROUP] != null) {
      if (match[_MINUTE_GROUP]!.length == 1 &&
          match[_AM_PM_HOUR_GROUP] == null) {
        // Skip single digit minute e.g. "at 1.1 xx"
        return null;
      }

      minute = int.parse(match[_MINUTE_GROUP]!);
    }

    if (minute >= 60) {
      return null;
    }

    if (hour > 12) {
      meridiem = Meridiem.PM;
    }

    // ----- AM & PM
    if (match[_AM_PM_HOUR_GROUP] != null) {
      if (hour > 12) return null;
      final ampm = match[_AM_PM_HOUR_GROUP]![0].toLowerCase();
      if (ampm == "a") {
        meridiem = Meridiem.AM;
        if (hour == 12) {
          hour = 0;
        }
      }

      if (ampm == "p") {
        meridiem = Meridiem.PM;
        if (hour != 12) {
          hour += 12;
        }
      }
    }

    components.assign(Component.hour, hour);
    components.assign(Component.minute, minute);

    if (meridiem != null) {
      components.assign(Component.meridiem, meridiem.id);
    } else {
      if (hour < 12) {
        components.imply(Component.meridiem, Meridiem.AM.id);
      } else {
        components.imply(Component.meridiem, Meridiem.PM.id);
      }
    }

    // ----- Millisecond
    if (match[_MILLI_SECOND_GROUP] != null) {
      final millisecond =
          int.parse(match[_MILLI_SECOND_GROUP]!.substring(0, 3));
      if (millisecond >= 1000) return null;

      components.assign(Component.millisecond, millisecond);
    }

    // ----- Second
    if (match[_SECOND_GROUP] != null) {
      final second = int.parse(match[_SECOND_GROUP]!);
      if (second >= 60) return null;

      components.assign(Component.second, second);
    }

    return components;
  }

  ParsingComponents? extractFollowingTimeComponents(
    ParsingContext context,
    RegExpMatch match,
    ParsingResult result,
  ) {
    final components = context.createParsingComponents();

    // ----- Millisecond
    if (match[_MILLI_SECOND_GROUP] != null) {
      final millisecond =
          int.parse(match[_MILLI_SECOND_GROUP]!.substring(0, 3));
      if (millisecond >= 1000) return null;

      components.assign(Component.millisecond, millisecond);
    }

    // ----- Second
    if (match[_SECOND_GROUP] != null) {
      final second = int.parse(match[_SECOND_GROUP]!);
      if (second >= 60) return null;

      components.assign(Component.second, second);
    }

    var hour = int.parse(match[_HOUR_GROUP]!);
    var minute = 0;
    var meridiem = -1;

    // ----- Minute
    if (match[_MINUTE_GROUP] != null) {
      minute = int.parse(match[_MINUTE_GROUP]!);
    } else if (hour > 100) {
      minute = hour % 100;
      hour = (hour / 100).floor();
    }

    if (minute >= 60 || hour > 24) {
      return null;
    }

    if (hour >= 12) {
      meridiem = Meridiem.PM.id;
    }

    // ----- AM & PM
    if (match[_AM_PM_HOUR_GROUP] != null) {
      if (hour > 12) {
        return null;
      }

      final ampm = match[_AM_PM_HOUR_GROUP]![0].toLowerCase();
      if (ampm == "a") {
        meridiem = Meridiem.AM.id;
        if (hour == 12) {
          hour = 0;
          if (!components.isCertain(Component.day)) {
            components.imply(Component.day, components.get(Component.day)! + 1);
          }
        }
      }

      if (ampm == "p") {
        meridiem = Meridiem.PM.id;
        if (hour != 12) hour += 12;
      }

      if (!result.start.isCertain(Component.meridiem)) {
        if (meridiem == Meridiem.AM.id) {
          result.start.imply(Component.meridiem, Meridiem.AM.id);

          if (result.start.get(Component.hour) == 12) {
            result.start.assign(Component.hour, 0);
          }
        } else {
          result.start.imply(Component.meridiem, Meridiem.PM.id);

          if (result.start.get(Component.hour) != 12) {
            result.start
                .assign(Component.hour, result.start.get(Component.hour)! + 12);
          }
        }
      }
    }

    components.assign(Component.hour, hour);
    components.assign(Component.minute, minute);

    if (meridiem >= 0) {
      components.assign(Component.meridiem, meridiem);
    } else {
      final startAtPM = result.start.isCertain(Component.meridiem) &&
          result.start.get(Component.hour)! > 12;
      if (startAtPM) {
        if (result.start.get(Component.hour)! - 12 > hour) {
          // 10pm - 1 (am)
          components.imply(Component.meridiem, Meridiem.AM.id);
        } else if (hour <= 12) {
          components.assign(Component.hour, hour + 12);
          components.assign(Component.meridiem, Meridiem.PM.id);
        }
      } else if (hour > 12) {
        components.imply(Component.meridiem, Meridiem.PM.id);
      } else if (hour <= 12) {
        components.imply(Component.meridiem, Meridiem.AM.id);
      }
    }

    if (components.date().millisecondsSinceEpoch <
        result.start.date().millisecondsSinceEpoch) {
      components.imply(Component.day, components.get(Component.day)! + 1);
    }

    return components;
  }

  T? _checkAndReturnWithoutFollowingPattern<T extends ParsingResult>(T result) {
    // Single digit (e.g "1") should not be counted as time expression (without proper context)
    if (RegExp(r'^\d$').hasMatch(result.text)) {
      return null;
    }

    // Three or more digit (e.g. "203", "2014") should not be counted as time expression (without proper context)
    if (RegExp(r'^\d\d\d+$').hasMatch(result.text)) {
      return null;
    }

    // Instead of "am/pm", it ends with "a" or "p" (e.g "1a", "123p"), this seems unlikely
    if (RegExp(r'\d[apAP]$').hasMatch(result.text)) {
      return null;
    }

    // If it ends only with numbers or dots
    final endingWithNumbers =
        RegExp(r'[^\d:.](\d[\d.]+)$').firstMatch(result.text);
    if (endingWithNumbers != null) {
      final String endingNumbers = endingWithNumbers[1]!;

      // In strict mode (e.g. "at 1" or "at 1.2"), this should not be accepted
      if (strictMode) {
        return null;
      }

      // If it ends only with dot single digit, e.g. "at 1.2"
      if (endingNumbers.contains(".") &&
          !RegExp(r'\d(\.\d{2})+$').hasMatch(endingNumbers)) {
        return null;
      }

      // If it ends only with numbers above 24, e.g. "at 25"
      final endingNumberVal = int.tryParse(endingNumbers);
      if ((endingNumberVal ?? 0) > 24) {
        return null;
      }
    }

    return result;
  }

  T? _checkAndReturnWithFollowingPattern<T extends ParsingResult>(T result) {
    if (RegExp(r'^\d+-\d+$').hasMatch(result.text)) {
      return null;
    }

    // If it ends only with numbers or dots
    final endingWithNumbers =
        RegExp(r'[^\d:.](\d[\d.]+)\s*-\s*(\d[\d.]+)$').firstMatch(result.text);
    if (endingWithNumbers != null) {
      // In strict mode (e.g. "at 1-3" or "at 1.2 - 2.3"), this should not be accepted
      if (strictMode) {
        return null;
      }

      final String startingNumbers = endingWithNumbers[1]!;
      final String endingNumbers = endingWithNumbers[2]!;
      // If it ends only with dot single digit, e.g. "at 1.2"
      if (endingNumbers.contains(".") &&
          !RegExp(r'\d(\.\d{2})+$').hasMatch(endingNumbers)) {
        return null;
      }

      // If it ends only with numbers above 24, e.g. "at 25"
      final endingNumberVal = int.parse(endingNumbers);
      final startingNumberVal = int.parse(startingNumbers);
      if (endingNumberVal > 24 || startingNumberVal > 24) {
        return null;
      }
    }

    return result;
  }

  String? _cachedPrimaryPrefix;
  String? _cachedPrimarySuffix;
  RegExp? _cachedPrimaryTimePattern;

  RegExp getPrimaryTimePatternThroughCache() {
    final primaryPrefix = this.primaryPrefix();
    final primarySuffix = this.primarySuffix();

    if (_cachedPrimaryPrefix == primaryPrefix &&
        _cachedPrimarySuffix == primarySuffix) {
      return _cachedPrimaryTimePattern!;
    }

    _cachedPrimaryTimePattern = primaryTimePattern(
        primaryPatternLeftBoundary(),
        primaryPrefix,
        primarySuffix,
        patternFlags());
    _cachedPrimaryPrefix = primaryPrefix;
    _cachedPrimarySuffix = primarySuffix;
    return _cachedPrimaryTimePattern!;
  }

  String? _cachedFollowingPhase;
  String? _cachedFollowingSuffix;
  RegExp? _cachedFollowingTimePattern;

  RegExp getFollowingTimePatternThroughCache() {
    final followingPhase = this.followingPhase();
    final followingSuffix = this.followingSuffix();

    if (_cachedFollowingPhase == followingPhase &&
        _cachedFollowingSuffix == followingSuffix) {
      return _cachedFollowingTimePattern!;
    }

    _cachedFollowingTimePattern =
        followingTimePatten(followingPhase, followingSuffix);
    _cachedFollowingPhase = followingPhase;
    _cachedFollowingSuffix = followingSuffix;
    return _cachedFollowingTimePattern!;
  }
}
