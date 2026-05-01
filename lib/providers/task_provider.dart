import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../isar_service.dart';
import '../models/task.dart';
import '../models/tag.dart';
import '../models/task_log.dart';

const _uuid = Uuid();

// ── Date helpers ─────────────────────────────────────────────────────────

String dateStr(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool taskAppearsOn(Task task, DateTime date) {
  final today = dateOnly(date);
  final start = dateOnly(task.startDate);
  switch (task.dateRule) {
    case DateRule.everyday:
      return true;
    case DateRule.specificDate:
      return start == today;
    case DateRule.deadline:
      if (task.endDate == null) return false;
      final end = dateOnly(task.endDate!);
      return !today.isBefore(start) && !today.isAfter(end);
    case DateRule.specificDays:
      return task.specificDays.contains(date.weekday);
  }
}

// ── Providers ─────────────────────────────────────────────────────────────

// FIX: use watch(fireImmediately: true) so the stream emits immediately
// even when the database is empty. This cures the infinite loading spinner.
final allTasksProvider = StreamProvider<List<Task>>((ref) {
  return IsarService.db.tasks
      .where()
      .watch(fireImmediately: true);  // <-- THE KEY FIX
});

// Derived provider: today's subset, no async needed
final todayTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasks = ref.watch(allTasksProvider);
  return tasks.whenData(
    (list) => list.where((t) => taskAppearsOn(t, DateTime.now())).toList(),
  );
});

// FIX: same fireImmediately fix for logs
final todayLogsProvider = StreamProvider<Map<String, TaskLog>>((ref) {
  final today = dateStr(DateTime.now());
  return IsarService.db.taskLogs
      .filter()
      .dateEqualTo(today)
      .watch(fireImmediately: true)  // <-- THE KEY FIX
      .map((logs) {
        final map = <String, TaskLog>{};
        for (final log in logs) { map[log.taskUuid] = log; }
        return map;
      });
});

// FIX: same fireImmediately fix for tags
final allTagsProvider = StreamProvider<List<Tag>>((ref) {
  return IsarService.db.tags
      .where()
      .watch(fireImmediately: true)  // <-- THE KEY FIX
      .map((tags) {
        tags.sort((a, b) => a.order.compareTo(b.order));
        return tags;
      });
});

// ── TaskService ───────────────────────────────────────────────────────────

class TaskService {

  static Future<void> saveTask(Task task) async {
    await IsarService.db.writeTxn(() async {
      await IsarService.db.tasks.put(task);
    });
  }

  // Delete a task and all its logs
  static Future<void> deleteTask(Task task) async {
    await IsarService.db.writeTxn(() async {
      // Delete the task
      await IsarService.db.tasks.delete(task.id);
      // Delete all daily logs for this task
      final logs = await IsarService.db.taskLogs
          .filter().taskUuidEqualTo(task.uuid).findAll();
      final logIds = logs.map((l) => l.id).toList();
      await IsarService.db.taskLogs.deleteAll(logIds);
    });
  }

  static Future<void> addProgress(Task task, double amount) async {
    final today = dateStr(DateTime.now());
    final existing = await IsarService.db.taskLogs
        .filter().taskUuidEqualTo(task.uuid).dateEqualTo(today).findFirst();

    final newProgress = (existing?.currentProgress ?? 0) + amount;
    final isCompleted = newProgress >= task.metricTarget;

    final log = existing ?? (TaskLog()
      ..taskUuid = task.uuid
      ..date = today
      ..currentProgress = 0
      ..isCompleted = false);

    log.currentProgress = newProgress;
    log.isCompleted = isCompleted;

    await IsarService.db.writeTxn(() async {
      await IsarService.db.taskLogs.put(log);
    });

    if (isCompleted && !(existing?.isCompleted ?? false)) {
      await _updateStreak(task);
    }
  }

  static Future<void> toggleBoolean(Task task, bool currentlyDone) async {
    if (currentlyDone) {
      await addProgress(task, -task.metricTarget);
    } else {
      await addProgress(task, task.metricTarget);
    }
  }

  static Future<void> _updateStreak(Task task) async {
    final today     = dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    int newStreak = 1;
    if (task.lastCompletedDate != null) {
      final last = dateOnly(task.lastCompletedDate!);
      if (last == yesterday) newStreak = task.currentStreak + 1;
    }
    await IsarService.db.writeTxn(() async {
      task.currentStreak = newStreak;
      task.lastCompletedDate = today;
      await IsarService.db.tasks.put(task);
    });
  }

  static Future<void> saveTag(Tag tag) async {
    await IsarService.db.writeTxn(() async {
      await IsarService.db.tags.put(tag);
    });
  }
}
