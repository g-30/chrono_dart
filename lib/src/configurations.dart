import './chrono.dart' show Configuration;
import './common/refiners/ExtractTimezoneAbbrRefiner.dart';
import './common/refiners/ExtractTimezoneOffsetRefiner.dart';
import './common/refiners/OverlapRemovalRefiner.dart';
import './common/refiners/ForwardDateRefiner.dart';
import './common/refiners/UnlikelyFormatFilter.dart';
import './common/parsers/ISOFormatParser.dart';
import './common/refiners/MergeWeekdayComponentRefiner.dart';

Configuration includeCommonConfiguration(Configuration configuration, [ bool strictMode = false ]) {
    configuration.parsers.insert(0, ISOFormatParser());

    configuration.refiners.insert(0, MergeWeekdayComponentRefiner());
    configuration.refiners.insert(0, ExtractTimezoneOffsetRefiner());
    configuration.refiners.insert(0, OverlapRemovalRefiner());

    // Unlike ExtractTimezoneOffsetRefiner, this refiner relies on knowing both date and time in cases where the tz
    // is ambiguous (in terms of DST/non-DST). It therefore needs to be applied as late as possible in the parsing.
    configuration.refiners.add(ExtractTimezoneAbbrRefiner());
    configuration.refiners.add(OverlapRemovalRefiner());
    configuration.refiners.add(ForwardDateRefiner());
    configuration.refiners.add(UnlikelyFormatFilter(strictMode));
    return configuration;
}
