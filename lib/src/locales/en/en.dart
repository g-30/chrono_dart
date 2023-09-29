/// Chrono components for English support (*parsers*, *refiners*, and *configuration*)
///
/// @module

import '../../chrono.dart' show Chrono;
import '../../types.dart' show ParsedResult, ParsingOption;

import './configuration.dart';

final enConfig = ENDefaultConfiguration();

/// Chrono object configured for parsing *casual* English
final casual = Chrono(enConfig.createCasualConfiguration(false));

/// Chrono object configured for parsing *strict* English
final strict = Chrono(enConfig.createConfiguration(true, false));

/// Chrono object configured for parsing *UK-style* English
final GB = Chrono(enConfig.createConfiguration(false, true));

/// A shortcut for en.casual.parse()
List<ParsedResult> parse(String text, [DateTime? ref, ParsingOption? option]) {
  return casual.parse(text, ref, option);
}

/// A shortcut for en.casual.parseDate()
DateTime? parseDate(String text, DateTime ref, ParsingOption option) {
  return casual.parseDate(text, ref, option);
}
