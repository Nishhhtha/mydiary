import 'package:idb_shim/idb.dart';         // ← exports Database, VersionChangeEvent, idbMode*
import 'package:idb_shim/idb_browser.dart';  // ← exports idbFactoryBrowser
import 'models/task.dart';
import 'models/tag.dart';
import 'models/task_log.dart';
import 'models/time_block.dart';

const _dbName    = 'planner_db';
const _dbVersion = 1;
const _tasks     = 'tasks';
const _tags      = 'tags';
const _logs      = 'task_logs';
const _blocks    = 'time_blocks';

class WebStorageService {
  static Database? _db;

  static Future<void> init() async {
    if (_db != null) return;
    _db = await idbFactoryBrowser.open(_dbName, version: _dbVersion,
        onUpgradeNeeded: (VersionChangeEvent e) {
      final db = e.database;
      if (!db.objectStoreNames.contains(_tasks))
        db.createObjectStore(_tasks, keyPath: 'uuid');
      if (!db.objectStoreNames.contains(_tags))
        db.createObjectStore(_tags,  keyPath: 'uuid');
      if (!db.objectStoreNames.contains(_logs))
        db.createObjectStore(_logs,  keyPath: 'uuid');
      if (!db.objectStoreNames.contains(_blocks))
        db.createObjectStore(_blocks, keyPath: 'uuid');
    });
  }

  static Database get db {
    if (_db == null) throw Exception('WebStorageService not initialised');
    return _db!;
  }

  // ── Tasks ─────────────────────────────────────────────────────────
  static Future<void> saveTask(Task task) async {
    final txn = db.transaction(_tasks, idbModeReadWrite);
    await txn.objectStore(_tasks).put(task.toMap());
    await txn.completed;
  }

  static Future<List<Task>> getAllTasks() async {
    final txn  = db.transaction(_tasks, idbModeReadOnly);
    final recs = await txn.objectStore(_tasks).getAll();
    await txn.completed;
    return recs.map((r) => Task.fromMap(r as Map)).toList();
  }

  static Future<void> deleteTask(String uuid) async {
    final txn = db.transaction(_tasks, idbModeReadWrite);
    await txn.objectStore(_tasks).delete(uuid);
    await txn.completed;
    final all = await getAllLogs();
    for (final log in all.where((l) => l.taskUuid == uuid)) {
      final t = db.transaction(_logs, idbModeReadWrite);
      await t.objectStore(_logs).delete(log.uuid);
      await t.completed;
    }
  }

  // ── Tags ──────────────────────────────────────────────────────────
  static Future<void> saveTag(Tag tag) async {
    final txn = db.transaction(_tags, idbModeReadWrite);
    await txn.objectStore(_tags).put(tag.toMap());
    await txn.completed;
  }

  static Future<List<Tag>> getAllTags() async {
    final txn  = db.transaction(_tags, idbModeReadOnly);
    final recs = await txn.objectStore(_tags).getAll();
    await txn.completed;
    return (recs.map((r) => Tag.fromMap(r as Map)).toList())
        ..sort((a, b) => a.order.compareTo(b.order));
  }

  static Future<void> deleteTag(String uuid) async {
  final txn = db.transaction(_tags, idbModeReadWrite);
  await txn.objectStore(_tags).delete(uuid);
  await txn.completed;
}

  // ── Logs ──────────────────────────────────────────────────────────
  static Future<TaskLog?> getLog(String taskUuid, String date) async {
    final all = await getAllLogs();
    try {
      return all.firstWhere((l) => l.taskUuid == taskUuid && l.date == date);
    } catch (_) { return null; }
  }

  static Future<List<TaskLog>> getAllLogs() async {
    final txn  = db.transaction(_logs, idbModeReadOnly);
    final recs = await txn.objectStore(_logs).getAll();
    await txn.completed;
    return recs.map((r) => TaskLog.fromMap(r as Map)).toList();
  }

  static Future<Map<String, TaskLog>> getLogsForDate(String date) async {
    final all = await getAllLogs();
    final map = <String, TaskLog>{};
    for (final l in all.where((l) => l.date == date)) {
      map[l.taskUuid] = l;
    }
    return map;
  }

  static Future<void> saveLog(TaskLog log) async {
    final txn = db.transaction(_logs, idbModeReadWrite);
    await txn.objectStore(_logs).put(log.toMap());
    await txn.completed;
  }

  // ── Time Blocks ───────────────────────────────────────────────────
  static Future<void> saveTimeBlock(TimeBlock block) async {
    final txn = db.transaction(_blocks, idbModeReadWrite);
    await txn.objectStore(_blocks).put(block.toMap());
    await txn.completed;
  }

  static bool _blockAppearsOn(TimeBlock block, DateTime date) {
    final today = DateTime(date.year, date.month, date.day);
    final start = DateTime(block.startDate.year, block.startDate.month, block.startDate.day);
    switch (block.dateRule) {
      case DateRule.everyday: return true;
      case DateRule.specificDate: return start == today;
      case DateRule.deadline:
        if (block.endDate == null) return false;
        final end = DateTime(block.endDate!.year, block.endDate!.month, block.endDate!.day);
        return !today.isBefore(start) && !today.isAfter(end);
      case DateRule.specificDays:
        return block.specificDays.contains(date.weekday);
      case DateRule.specificDatePeriod:
        if (block.endDate == null) return false;
        final end = DateTime(block.endDate!.year, block.endDate!.month, block.endDate!.day);
        return !today.isBefore(start) && !today.isAfter(end);
    }
  }

  static Future<List<TimeBlock>> getBlocksForDate(String dateStr) async {
    final date = DateTime.parse(dateStr);
    final txn  = db.transaction(_blocks, idbModeReadOnly);
    final recs = await txn.objectStore(_blocks).getAll();
    await txn.completed;
    final blocks = recs
        .map((r) => TimeBlock.fromMap(r as Map))
        .where((b) => _blockAppearsOn(b, date))
        .toList();
    blocks.sort((a, b) => a.startMinute.compareTo(b.startMinute));
    return blocks;
  }

  static Future<void> deleteTimeBlock(String uuid) async {
    final txn = db.transaction(_blocks, idbModeReadWrite);
    await txn.objectStore(_blocks).delete(uuid);
    await txn.completed;
  }
}