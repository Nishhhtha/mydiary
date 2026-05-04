enum DateRule { specificDate, everyday, deadline, specificDays }
enum MetricType { boolean, numeric }

class Task {
  final String uuid;
  final String title;
  final String description;
  final String tagUuid;
  final MetricType metricType;
  final String? metricUnit;
  final double metricTarget;
  final DateRule dateRule;
  final DateTime startDate;
  final DateTime? endDate;
  final int currentStreak;
  final DateTime? lastCompletedDate;
  final List<int> specificDays;

  Task({
    required this.uuid,
    required this.title,
    this.description = '',
    required this.tagUuid,
    required this.metricType,
    this.metricUnit,
    this.metricTarget = 1.0,
    required this.dateRule,
    required this.startDate,
    this.endDate,
    this.currentStreak = 0,
    this.lastCompletedDate,
    this.specificDays = const [],
});

  Map<String, dynamic> toMap() => {
    'uuid': uuid, 'title': title, 'description': description,
    'tagUuid': tagUuid,
    'metricType': metricType.name,
    'metricUnit': metricUnit,
    'metricTarget': metricTarget,
    'dateRule': dateRule.name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'currentStreak': currentStreak,
    'lastCompletedDate': lastCompletedDate?.toIso8601String(),
    'specificDays': specificDays,
  };

  factory Task.fromMap(Map<dynamic, dynamic> m) => Task(
    uuid:              m['uuid'] as String,
    title:             m['title'] as String,
    description:       m['description'] as String? ?? '',
    tagUuid:           m['tagUuid'] as String,
    metricType:        MetricType.values.byName(m['metricType'] as String),
    metricUnit:        m['metricUnit'] as String?,
    metricTarget:      (m['metricTarget'] as num).toDouble(),
    dateRule:          DateRule.values.byName(m['dateRule'] as String),
    startDate:         DateTime.parse(m['startDate'] as String),
    endDate:           m['endDate'] != null
                         ? DateTime.parse(m['endDate'] as String) : null,
    currentStreak:     (m['currentStreak'] as num?)?.toInt() ?? 0,
    lastCompletedDate: m['lastCompletedDate'] != null
                         ? DateTime.parse(m['lastCompletedDate'] as String) : null,
    specificDays:      (m['specificDays'] as List?)?.cast<int>() ?? [],
  );

  Task copyWith({int? currentStreak, DateTime? lastCompletedDate}) => Task(
    uuid: uuid, title: title, description: description,
    tagUuid: tagUuid, metricType: metricType, metricUnit: metricUnit,
    metricTarget: metricTarget, dateRule: dateRule,
    startDate: startDate, endDate: endDate,
    currentStreak: currentStreak ?? this.currentStreak,
    lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    specificDays: specificDays,
  );
}
