// ignore_for_file: constant_identifier_names

class ParsingOption {
  /// To parse only forward dates (the results should be after the reference date).
  /// This effects date/time implication (e.g. weekday or time mentioning)
  final bool? forwardDate;

  /// Additional timezone keywords for the parsers to recognize.
  /// Any value provided will override the default handling of that value.
  final TimezoneAbbrMap? timezones;

  ParsingOption({this.forwardDate, this.timezones});

  /// Internal debug event handler.
  /// @internal
  dynamic debug;
}

/// Some timezone abbreviations are ambiguous in that they refer to different offsets
/// depending on the time of year — daylight savings time (DST), or non-DST. This interface
/// allows defining such timezones
abstract class AmbiguousTimezoneMap {
  num get timezoneOffsetDuringDst;
  num get timezoneOffsetNonDst;

  /// Return the start date of DST for the given year.
  /// timezone.ts contains helper methods for common such rules.
  DateTime dstStart(num year);

  /// Return the end date of DST for the given year.
  /// timezone.ts contains helper methods for common such rules.
  DateTime dstEnd(num year);
}

/// A map describing how timezone abbreviations should map to time offsets.
/// Supports both unambigous mappings abbreviation => offset,
/// and ambiguous mappings, where the offset will depend on whether the
/// time in question is during daylight savings time or not.
typedef TimezoneAbbrMap = Map<String, dynamic>;

class ParsingReference {
  /// Reference date. The instant (JavaScript Date object) when the input is written or mention.
  /// This effect date/time implication (e.g. weekday or time mentioning).
  /// (default = now)
  DateTime? instant;

  /// Reference timezone. The timezone where the input is written or mention.
  /// Date/time implication will account the difference between input timezone and the current system timezone.
  /// (default = current timezone)
  /// string | number
  dynamic timezone;

  ParsingReference({this.instant, this.timezone});
}

/// Parsed result or final output.
/// Each result object represents a date/time (or date/time-range) mentioning in the input.
abstract class ParsedResult {
  DateTime get refDate;
  num get index;
  String get text;

  ParsedComponents get start;
  ParsedComponents? get end;

  /// @return a javascript date object created from the `result.start`.
  DateTime date();

  /// @return debugging tags combined of the `result.start` and `result.end`.
  Set<String> tags();
}

/// A collection of parsed date/time components (e.g. day, hour, minute, ..., etc).
///
/// Each parsed component has three different levels of certainty.
/// - *Certain* (or *Known*): The component is directly mentioned and parsed.
/// - *Implied*: The component is not directly mentioned, but implied by other parsed information.
/// - *Unknown*: Completely no mention of the component.
abstract class ParsedComponents {
  /// Check the component certainly if the component is *Certain* (or *Known*)
  bool isCertain(Component component);

  /// Get the component value for either *Certain* or *Implied* value.
  num? get(Component component);

  /// @return a javascript date object.
  DateTime date();

  /// @return debugging tags of the parsed component.
  Set<String> tags();
}

enum Component {
  year,
  month,
  day,
  weekday,
  hour,
  minute,
  second,
  millisecond,
  meridiem,
  timezoneOffset,
}

mixin EnumId {
  /// Overridable enum element ID.
  int get id;
}

enum Meridiem implements EnumId {
  AM,
  PM;

  @override
  int get id => index;
}

enum Weekday implements EnumId {
  SUNDAY,
  MONDAY,
  TUESDAY,
  WEDNESDAY,
  THURSDAY,
  FRIDAY,
  SATURDAY;

  @override
  int get id => index;

  static Weekday weekById(int id) =>
      id == 0 || id == 7 ? SUNDAY : Weekday.values.asMap()[id]!;
}

enum Month implements EnumId {
  JANUARY,
  FEBRUARY,
  MARCH,
  APRIL,
  MAY,
  JUNE,
  JULY,
  AUGUST,
  SEPTEMBER,
  OCTOBER,
  NOVEMBER,
  DECEMBER;

  @override
  int get id => index + 1;
}

class RegExpChronoMatch {
  final RegExpMatch original;

  final List<String?> _groups;

  RegExpChronoMatch(this.original)
      : index = original.start,
        _groups = List.generate(
            original.groupCount, (index) => original.group(index),
            growable: false);

  int get groupCount => original.groupCount;

  String? operator [](int group) => _groups[group];
  void operator []=(int index, String? value) {
    _groups[index] = value;
  }

  int index;
}
