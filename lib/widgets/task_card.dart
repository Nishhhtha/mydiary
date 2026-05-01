import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/tag.dart';
import '../models/task_log.dart';
import '../providers/task_provider.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Tag? tag;
  final TaskLog? log;

  const TaskCard({super.key, required this.task, this.tag, this.log});

  @override
  Widget build(BuildContext context) {
    final progress    = log?.currentProgress ?? 0.0;
    final isCompleted = log?.isCompleted ?? false;
    final cardColor   = isCompleted
        ? Colors.grey.shade200
        : (tag?.color.withOpacity(0.35) ?? const Color(0xFFB2EBF2));

    // GestureDetector wraps the whole card to catch long-press for delete
    return GestureDetector(
      onLongPress: () => _confirmDelete(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          // ── Circle checkbox ─────────────────────────────────────────
          GestureDetector(
            onTap: () {
              if (task.metricType == MetricType.boolean) {
                TaskService.toggleBoolean(task, isCompleted);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black45, width: 2),
                color: isCompleted ? Colors.black45 : Colors.transparent,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // ── Title + progress ────────────────────────────────────────
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Flexible(child: Text(task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ))),
                if (task.dateRule == DateRule.deadline && task.endDate != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Due ${_fmt(task.endDate!)}',
                        style: const TextStyle(fontSize: 11, color: Colors.red)),
                  ),
                ],
              ]),
              if (task.metricType == MetricType.numeric) ...[
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (progress / task.metricTarget).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.black12,
                    valueColor: AlwaysStoppedAnimation(
                      isCompleted ? Colors.green : Theme.of(context).colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_num(progress)} / ${_num(task.metricTarget)} ${task.metricUnit ?? ''}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ],
          )),
          // ── Streak ──────────────────────────────────────────────────
          if (task.currentStreak > 0)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${task.currentStreak} \uD83D\uDD25',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          // ── + button ────────────────────────────────────────────────
          if (task.metricType == MetricType.numeric)
            IconButton(
              icon: Icon(Icons.add_circle,
                  size: 34,
                  color: isCompleted
                      ? Colors.grey
                      : Theme.of(context).colorScheme.primary),
              onPressed: isCompleted ? null : () => _showAddDialog(context),
            ),
        ]),
      ),
    );
  }

  // Shows a confirmation dialog before deleting
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text(
          'Delete "${task.title}"?\n\nThis will also remove all progress logs for this task. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              TaskService.deleteTask(task);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add ${task.metricUnit ?? 'progress'}'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'e.g. 2000',
            suffixText: task.metricUnit,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              if (val != null && val > 0) TaskService.addProgress(task, val);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month-1]}';
  }

  String _num(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);
}