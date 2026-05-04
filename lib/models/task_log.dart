class TaskLog {
  final String uuid;       // NEW: added for IndexedDB key (was Isar auto-int Id)
  final String taskUuid;
  final String date;       // 'YYYY-MM-DD'
  final double currentProgress;
  final bool isCompleted;

  TaskLog({
    required this.uuid,
    required this.taskUuid,
    required this.date,
    this.currentProgress = 0,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
    'uuid': uuid, 'taskUuid': taskUuid, 'date': date,
    'currentProgress': currentProgress, 'isCompleted': isCompleted,
  };

  factory TaskLog.fromMap(Map<dynamic, dynamic> m) => TaskLog(
    uuid:            m['uuid'] as String,
    taskUuid:        m['taskUuid'] as String,
    date:            m['date'] as String,
    currentProgress: (m['currentProgress'] as num?)?.toDouble() ?? 0,
    isCompleted:     m['isCompleted'] as bool? ?? false,
  );

  TaskLog copyWith({double? currentProgress, bool? isCompleted}) => TaskLog(
    uuid: uuid, taskUuid: taskUuid, date: date,
    currentProgress: currentProgress ?? this.currentProgress,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}
