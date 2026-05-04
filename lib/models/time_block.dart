import 'task.dart';

class TimeBlock {
  final String uuid;
  final String label;
  final int startMinute;
  final int endMinute;
  final String colorHex;
  final DateRule dateRule;
  final DateTime startDate;
  final DateTime? endDate;
  final List<int> specificDays;

  TimeBlock({
    required this.uuid,
    required this.label,
    required this.startMinute,
    required this.endMinute,
    required this.colorHex,
    required this.dateRule,
    required this.startDate,
    this.endDate,
    this.specificDays = const [],
  });

  String get startLabel => _toTime(startMinute);
  String get endLabel   => _toTime(endMinute);
  int get durationMinutes => endMinute - startMinute;

  static String _toTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final period = h < 12 ? 'AM' : 'PM';
    final hour   = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hour:${m.toString().padLeft(2,'0')} $period';
  }

  Map<String, dynamic> toMap() => {
    'uuid': uuid,
    'label': label,
    'startMinute': startMinute,
    'endMinute': endMinute,
    'colorHex': colorHex,
    'dateRule': dateRule.name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'specificDays': specificDays,
  };

  factory TimeBlock.fromMap(Map<dynamic, dynamic> m) {
    final dateStr = m['date'] as String?;
    DateTime start;
    DateRule rule;

    if (m.containsKey('dateRule')) {
      rule = DateRule.values.byName(m['dateRule'] as String);
      start = DateTime.parse(m['startDate'] as String);
    } else if (dateStr != null) {
      rule = DateRule.specificDate;
      start = DateTime.parse(dateStr);
    } else {
      rule = DateRule.specificDate;
      start = DateTime.now();
    }

    return TimeBlock(
      uuid:        m['uuid'] as String,
      label:       m['label'] as String,
      startMinute: (m['startMinute'] as num).toInt(),
      endMinute:   (m['endMinute'] as num).toInt(),
      colorHex:    m['colorHex'] as String,
      dateRule:    rule,
      startDate:   start,
      endDate:     m['endDate'] != null ? DateTime.parse(m['endDate'] as String) : null,
      specificDays:(m['specificDays'] as List?)?.cast<int>() ?? [],
    );
  }
}
