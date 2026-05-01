import 'package:isar/isar.dart';

part 'task_log.g.dart';

@collection
class TaskLog {
  Id id = Isar.autoIncrement;

  late String taskUuid;         // Which task this log belongs to
  late String date;             // Format: '2026-04-14'
  late double currentProgress;  // e.g. 6500.0 (steps logged today)
  late bool isCompleted;

  TaskLog();
}
