// ignore_for_file: constant_identifier_names
import 'package:day/day.dart' as dayjs;
import '../../../chrono.dart' show ParsingContext;
import '../../../types.dart' show RegExpChronoMatch, Component;
import '../constants.dart'
    show TIME_UNIT_DICTIONARY;
    import '../../../results.dart' show ParsingComponents;
import '../../../common/parsers/AbstractParserWithWordBoundary.dart';
import '../../../utils/pattern.dart' show matchAnyPattern;

final _pattern = RegExp(
    "(this|last|past|next|after\\s*this)\\s*(${matchAnyPattern(TIME_UNIT_DICTIONARY)})(?=\\s*)(?=\\W|\$)",
    caseSensitive: false,
);

const _MODIFIER_WORD_GROUP = 1;
const _RELATIVE_WORD_GROUP = 2;

class ENRelativeDateFormatParser extends AbstractParserWithWordBoundaryChecking {
    @override
    RegExp innerPattern(context) {
        return _pattern;
    }

    @override
    ParsingComponents innerExtract(ParsingContext context, RegExpChronoMatch match) {
        final modifier = match[_MODIFIER_WORD_GROUP]!.toLowerCase();
        final unitWord = match[_RELATIVE_WORD_GROUP]!.toLowerCase();
        final timeunit = TIME_UNIT_DICTIONARY[unitWord]!;

        if (modifier == "next" || modifier.startsWith("after")) {
            final Map<String, num> timeUnits = {};
            timeUnits[timeunit] = 1;
            return ParsingComponents.createRelativeFromReference(context.reference, timeUnits);
        }

        if (modifier == "last" || modifier == "past") {
            final Map<String, num> timeUnits = {};
            timeUnits[timeunit] = -1;
            return ParsingComponents.createRelativeFromReference(context.reference, timeUnits);
        }

        final components = context.createParsingComponents();
        var date = dayjs.Day.fromDateTime(context.reference.instant);

        // This week
        if (RegExp(r'week', caseSensitive: false).hasMatch(unitWord)) {
            date = date.add(-date.get("d")!, "d")!;
            components.imply(Component.day, date.date());
            components.imply(Component.month, date.month());
            components.imply(Component.year, date.year());
        }

        // This month
        else if (RegExp(r'month', caseSensitive: false).hasMatch(unitWord)) {
            date = date.add(-date.date() + 1, "d")!;
            components.imply(Component.day, date.date());
            components.assign(Component.year, date.year());
            components.assign(Component.month, date.month());
        }

        // This year
        else if (RegExp(r'year', caseSensitive: false).hasMatch(unitWord)) {
            date = date.add(-date.date() + 1, "d")!;
            date = date.add(-date.month(), "month")!;

            components.imply(Component.day, date.date());
            components.imply(Component.month, date.month());
            components.assign(Component.year, date.year());
        }

        return components;
    }
}
