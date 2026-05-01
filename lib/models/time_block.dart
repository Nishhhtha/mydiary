import 'package:isar/isar.dart';

part 'time_block.g.dart';

@collection
class TimeBlock {
  Id id = Isar.autoIncrement;

  late String uuid;
  late String label;      // e.g. 'Study', 'Breakfast'
  late String date;       // 'YYYY-MM-DD' — which day this block belongs to
  late int startMinute;   // Minutes from midnight, e.g. 8:30 AM = 510
  late int endMinute;     // e.g. 9:30 AM = 570
  late String colorHex;   // Card colour, e.g. 'FF4CAF50'

  TimeBlock();

  // Convenience: readable time strings
  String get startLabel => _toTime(startMinute);
  String get endLabel   => _toTime(endMinute);
  int get durationMinutes => endMinute - startMinute;

  static String _toTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final period = h < 12 ? 'AM' : 'PM';
    final hour   = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${hour}:${m.toString().padLeft(2,'0')} $period';
  }
}
