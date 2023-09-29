/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import './src/locales/en/en.dart' as en;
import './src/types.dart' show ParsedResult, ParsingOption, ParsingReference;

export './src/chrono.dart';
export './src/types.dart';
export './src/results.dart';

// export { en, Chrono, Parser, Refiner, ParsingResult, ParsingComponents, ReferenceWithTimezone }
// export { Component, ParsedComponents, ParsedResult, ParsingOption, ParsingReference, Meridiem, Weekday }

// export { de, fr, ja, pt, nl, zh, ru, es, uk }

/// A shortcut for {@link en | chrono.en.strict}
final strict = en.strict;

/// A shortcut for {@link en | chrono.en.casual}
final casual = en.casual;

/// A shortcut for {@link en | chrono.en.casual.parse()}
List<ParsedResult> parse(String text, {dynamic ref, ParsingOption? option}) {
  assert(ref == null || ref is ParsingReference || ref is DateTime,
      'ref must be either null, DateTime or ParsingReference');
  return casual.parse(text, ref, option);
}

/// A shortcut for {@link en | chrono.en.casual.parseDate()}
DateTime? parseDate(String text, {dynamic ref, ParsingOption? option}) {
  assert(ref == null || ref is ParsingReference || ref is DateTime,
      'ref must be either null, DateTime or ParsingReference');
  return casual.parseDate(text, ref, option);
}


// TODO: Export any libraries intended for clients of this package.
