
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../models/tag.dart';
import '../widgets/task_card.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});
  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  String? _selectedTagUuid; // null = show All

  @override
  Widget build(BuildContext context) {
    //final todayTasks = ref.watch(todayTasksProvider);
    // NEW (replace with this):
    final todayTasksValue = ref.watch(todayTasksProvider);
    final todayTasks = todayTasksValue.valueOrNull ?? [];

    final logsAsync  = ref.watch(todayLogsProvider);
    final tagsAsync  = ref.watch(allTagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Today — ${_fmtDate()}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: tagsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,_) => Center(child: Text('Error: $e')),
        data: (tags) {
          // Build tag map for quick colour lookup
          final tagMap = { for (var t in tags) t.uuid: t };

          // Filter tasks by selected tag
          final filtered = _selectedTagUuid == null
              ? todayTasks
              : todayTasks.where((t) => t.tagUuid == _selectedTagUuid).toList();

          // Only show tags that have tasks today
          final activeTags = tags.where(
              (tag) => todayTasks.any((t) => t.tagUuid == tag.uuid)).toList();

          return Column(children: [
            _filterBar(activeTags),
            Expanded(
              child: filtered.isEmpty
                ? const Center(child: Text('No tasks for today — enjoy your day!',
                    style: TextStyle(color: Colors.grey)))
                : logsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e,_) => Center(child: Text('Error: $e')),
                    data: (logs) => ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final task = filtered[i];
                        final tag  = tagMap[task.tagUuid];
                        final log  = logs[task.uuid];
                        return TaskCard(task: task, tag: tag, log: log);
                      },
                    ),
                  ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _filterBar(List<Tag> tags) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: [
        _chip(null, 'All', Colors.grey.shade200),
        ...tags.map((t) => _chip(t.uuid, t.name, t.color.withOpacity(0.25))),
      ]),
    );
  }

  Widget _chip(String? uuid, String label, Color bgColor) {
    final selected = _selectedTagUuid == uuid;
    return GestureDetector(
      onTap: () => setState(() => _selectedTagUuid = uuid),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? bgColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.black38 : Colors.transparent, width: 1.5),
        ),
        child: Text(label,
            style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  String _fmtDate() {
    final n = DateTime.now();
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${n.day} ${m[n.month-1]}';
  }
}
