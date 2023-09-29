import '../../chrono.dart' show Configuration;

import './parsers/ENTimeUnitWithinFormatParser.dart';
import './parsers/ENMonthNameLittleEndianParser.dart';
import './parsers/ENMonthNameMiddleEndianParser.dart';
import './parsers/ENMonthNameParser.dart';
import './parsers/ENCasualYearMonthDayParser.dart';
import './parsers/ENSlashMonthFormatParser.dart';
import './parsers/ENTimeExpressionParser.dart';
import './parsers/ENTimeUnitAgoFormatParser.dart';
import './parsers/ENTimeUnitLaterFormatParser.dart';
import './refiners/ENMergeDateRangeRefiner.dart';
import './refiners/ENMergeDateTimeRefiner.dart';

import '../../configurations.dart' show includeCommonConfiguration;
import './parsers/ENCasualDateParser.dart';
import './parsers/ENCasualTimeParser.dart';
import './parsers/ENWeekdayParser.dart';
import './parsers/ENRelativeDateFormatParser.dart';

import '../../common/parsers/SlashDateFormatParser.dart';
import './parsers/ENTimeUnitCasualRelativeFormatParser.dart';
import './refiners/ENMergeRelativeDateRefiner.dart';

class ENDefaultConfiguration {
  const ENDefaultConfiguration();

    /// Create a default *casual* {@Link Configuration} for English chrono.
    /// It calls {@Link createConfiguration} and includes additional parsers.
    Configuration createCasualConfiguration([ bool littleEndian = false ]) {
        final option = createConfiguration(false, littleEndian);
        option.parsers.insert(0, ENCasualDateParser());
        option.parsers.insert(0, ENCasualTimeParser());
        option.parsers.insert(0, ENMonthNameParser());
        option.parsers.insert(0, ENRelativeDateFormatParser());
        option.parsers.insert(0, ENTimeUnitCasualRelativeFormatParser());
        return option;
    }

    /// Create a default {@Link Configuration} for English chrono
    ///
    /// @param strictMode If the timeunit mentioning should be strict, not casual
    /// @param littleEndian If format should be date-first/littleEndian (e.g. en_UK), not month-first/middleEndian (e.g. en_US)
    Configuration createConfiguration([ bool strictMode = true, bool littleEndian = false ]) {
        final options = includeCommonConfiguration(
            Configuration(
                parsers: [
                    SlashDateFormatParser(littleEndian),
                    ENTimeUnitWithinFormatParser(strictMode),
                    ENMonthNameLittleEndianParser(),
                    ENMonthNameMiddleEndianParser(),
                    ENWeekdayParser(),
                    ENCasualYearMonthDayParser(),
                    ENSlashMonthFormatParser(),
                    ENTimeExpressionParser(strictMode),
                    ENTimeUnitAgoFormatParser(strictMode),
                    ENTimeUnitLaterFormatParser(strictMode),
                ],
                refiners: [ENMergeRelativeDateRefiner(), ENMergeDateTimeRefiner()],
            ),
            strictMode
        );
        // Re-apply the date time refiner again after the timezone refinement and exclusion in common refiners.
        options.refiners.add(ENMergeDateTimeRefiner());
        // Keep the date range refiner at the end (after all other refinements).
        options.refiners.add(ENMergeDateRangeRefiner());
        return options;
    }
}
