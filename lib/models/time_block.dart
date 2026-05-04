class TimeBlock {
  final String uuid;
  final String label;
  final String date;
  final int startMinute;
  final int endMinute;
  final String colorHex;

  TimeBlock({
    required this.uuid, required this.label,
    required this.date, required this.startMinute,
    required this.endMinute, required this.colorHex,
  });

  // These getters are identical to your current time_block.dart
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
    'uuid': uuid, 'label': label, 'date': date,
    'startMinute': startMinute, 'endMinute': endMinute,
    'colorHex': colorHex,
  };

  factory TimeBlock.fromMap(Map<dynamic, dynamic> m) => TimeBlock(
    uuid:        m['uuid'] as String,
    label:       m['label'] as String,
    date:        m['date'] as String,
    startMinute: (m['startMinute'] as num).toInt(),
    endMinute:   (m['endMinute'] as num).toInt(),
    colorHex:    m['colorHex'] as String,
  );
}
