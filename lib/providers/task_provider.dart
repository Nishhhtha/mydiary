import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../web_storage_service.dart'; // <-- only change from your current version
import '../models/task.dart';
import '../models/tag.dart';
import '../models/task_log.dart';

const _uuid = Uuid();

// ── Date helpers — IDENTICAL to your current code ─────────────────────────

String dateStr(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool taskAppearsOn(Task task, DateTime date) {
  final today = dateOnly(date);
  final start = dateOnly(task.startDate);
  switch (task.dateRule) {
    case DateRule.everyday: return true;
    case DateRule.specificDate: return start == today;
    case DateRule.deadline:
      if (task.endDate == null) return false;
      final end = dateOnly(task.endDate!);
      return !today.isBefore(start) && !today.isAfter(end);
    case DateRule.specificDays:
      return task.specificDays.contains(date.weekday);
  }
}

// ── Providers — same structure as your current code ───────────────────────

// Notifier holds all tasks and can refresh after writes
class TasksNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() => WebStorageService.getAllTasks();
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(WebStorageService.getAllTasks);
  }
}
final allTasksProvider =
    AsyncNotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);

// PRESERVED: selectedDateTasksProvider — identical family pattern to your code
final selectedDateTasksProvider =
    Provider.family<AsyncValue<List<Task>>, DateTime>((ref, date) {
  final tasks = ref.watch(allTasksProvider);
  return tasks.whenData(
    (list) => list.where((t) => taskAppearsOn(t, date)).toList(),
  );
});

// PRESERVED: todayTasksProvider — kept for backward compatibility
final todayTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasks = ref.watch(allTasksProvider);
  return tasks.whenData(
    (list) => list.where((t) => taskAppearsOn(t, DateTime.now())).toList(),
  );
});

// Notifier for tags
class TagsNotifier extends AsyncNotifier<List<Tag>> {
  @override
  Future<List<Tag>> build() => WebStorageService.getAllTags();
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(WebStorageService.getAllTags);
  }
}
final allTagsProvider =
    AsyncNotifierProvider<TagsNotifier, List<Tag>>(TagsNotifier.new);

// Notifier for logs on a specific date — used by tasksLogsForDateProvider
class LogsForDateNotifier
    extends FamilyAsyncNotifier<Map<String, TaskLog>, DateTime> {
  @override
  Future<Map<String, TaskLog>> build(DateTime arg) {
    return WebStorageService.getLogsForDate(dateStr(arg));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => WebStorageService.getLogsForDate(dateStr(arg)));
  }
}

final tasksLogsForDateProvider =
    AsyncNotifierProvider.family<LogsForDateNotifier,
        Map<String, TaskLog>, DateTime>(
  LogsForDateNotifier.new,
);

// PRESERVED: todayLogsProvider — kept for backward compatibility
final todayLogsProvider =
    Provider<AsyncValue<Map<String, TaskLog>>>((ref) {
  return ref.watch(tasksLogsForDateProvider(DateTime.now()));
});

// ── TaskService — same method signatures as your current code ─────────────
// NOTE: Methods now take a WidgetRef to refresh providers after writes.
// Your screens already have ref available (they are ConsumerStatefulWidgets).

class TaskService {

  static Future<void> saveTask(Task task, WidgetRef ref) async {
    await WebStorageService.saveTask(task);
    await ref.read(allTasksProvider.notifier).refresh();
  }

  static Future<void> deleteTask(Task task, WidgetRef ref) async {
    await WebStorageService.deleteTask(task.uuid);
    await ref.read(allTasksProvider.notifier).refresh();
  }

  static Future<void> addProgress(
      Task task, double amount, WidgetRef ref) async {
    final today    = dateStr(DateTime.now());
    final existing = await WebStorageService.getLog(task.uuid, today);
    final newProg  = (existing?.currentProgress ?? 0) + amount;
    final isDone   = newProg >= task.metricTarget;
    final log = TaskLog(
      uuid:            existing?.uuid ?? _uuid.v4(),
      taskUuid:        task.uuid,
      date:            today,
      currentProgress: newProg,
      isCompleted:     isDone,
    );
    await WebStorageService.saveLog(log);
    if (isDone && !(existing?.isCompleted ?? false)) {
      await _updateStreak(task, ref);
    }
    await ref.read(tasksLogsForDateProvider(DateTime.now()).notifier).refresh();
  }

  static Future<void> toggleBoolean(
      Task task, bool currentlyDone, WidgetRef ref) async {
    await addProgress(
      task,
      currentlyDone ? -task.metricTarget : task.metricTarget,
      ref,
    );
  }

  static Future<void> saveTag(Tag tag, WidgetRef ref) async {
    await WebStorageService.saveTag(tag);
    await ref.read(allTagsProvider.notifier).refresh();
  }

  static Future<void> _updateStreak(Task task, WidgetRef ref) async {
    final today     = dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    int newStreak   = 1;
    if (task.lastCompletedDate != null) {
      if (dateOnly(task.lastCompletedDate!) == yesterday) {
        newStreak = task.currentStreak + 1;
      }
    }
    final updated = task.copyWith(
      currentStreak: newStreak, lastCompletedDate: today);
    await WebStorageService.saveTask(updated);
    await ref.read(allTasksProvider.notifier).refresh();
  }
}
