import 'package:day/day.dart' as dayjs;

/// Find the most likely year, from a raw number. For example:
/// 1997 => 1997
/// 97 => 1997
/// 12 => 2012
int findMostLikelyADYear(int yearNumber) {
  if (yearNumber < 100) {
    if (yearNumber > 50) {
      yearNumber = yearNumber + 1900;
    } else {
      yearNumber = yearNumber + 2000;
    }
  }

  return yearNumber;
}

int findYearClosestToRef(DateTime refDate, int day, int month) {
  //Find the most appropriated year
  final refMoment = dayjs.Day.fromDateTime(refDate);
  var dateMoment = refMoment;
  dateMoment = dateMoment.month(month - 1);
  dateMoment = dateMoment.date(day);
  dateMoment = dateMoment.year(refMoment.year());

  final nextYear = dateMoment.add(1, "y")!;
  final lastYear = dateMoment.add(-1, "y")!;
  if (nextYear.diff(refMoment).abs() < dateMoment.diff(refMoment).abs()) {
    dateMoment = nextYear;
  } else if (lastYear.diff(refMoment).abs() <
      dateMoment.diff(refMoment).abs()) {
    dateMoment = lastYear;
  }

  return dateMoment.year();
}
