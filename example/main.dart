import 'package:chrono_dart/chrono_dart.dart' show Chrono;

void main() {
  final dateOrNull = Chrono.parseDate('An appointment on Sep 12');
  print('Found date: $dateOrNull');

  final results = Chrono.parse('An appointment on Sep 12');
  print('Found dates: $results');
}