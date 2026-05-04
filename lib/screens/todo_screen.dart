import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../models/tag.dart';
import '../widgets/task_card.dart';

class TodoScreen extends ConsumerStatefulWidget {
  final DateTime? selectedDate;
  
  const TodoScreen({super.key, this.selectedDate});
  
  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  String? _selectedTagUuid;
  late DateTime _displayDate;

  @override
  void initState() {
    super.initState();
    _displayDate = widget.selectedDate ?? DateTime.now();
  }

  @override
  void didUpdateWidget(TodoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != null && 
        widget.selectedDate != oldWidget.selectedDate) {
      setState(() {
        _displayDate = widget.selectedDate!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIXED: Use the new selectedDateTasksProvider to get tasks for the specific date
    final tasksForDateValue = ref.watch(selectedDateTasksProvider(_displayDate));
    final tasksForDate = tasksForDateValue.valueOrNull ?? [];

    // FIXED: Use the new tasksLogsForDateProvider to get logs for the specific date
    final logsAsync = ref.watch(tasksLogsForDateProvider(_displayDate));
    final tagsAsync = ref.watch(allTagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${_fmtDate(_displayDate)}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: tagsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,_) => Center(child: Text('Error: $e')),
        data: (tags) {
          final tagMap = { for (var t in tags) t.uuid: t };

          final filtered = _selectedTagUuid == null
              ? tasksForDate
              : tasksForDate.where((t) => t.tagUuid == _selectedTagUuid).toList();

          final activeTags = tags.where(
              (tag) => tasksForDate.any((t) => t.tagUuid == tag.uuid)).toList();

          return Column(children: [
            _filterBar(activeTags),
            Expanded(
              child: filtered.isEmpty
                ? const Center(child: Text('No tasks for this day — enjoy!',
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
        ...tags.map((t) => _chip(t.uuid, t.name, t.color)),
      ]),
    );
  }

  Widget _chip(String? uuid, String label, Color bgColor) 
  {
    final selected = _selectedTagUuid == uuid;
    return GestureDetector(
      onTap: () => setState(() => _selectedTagUuid = uuid),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          // Always show tag colour — full opacity when selected, faint when not
          color: uuid == null
              ? (selected ? Colors.grey.shade400 : Colors.grey.shade200)
              : (selected ? bgColor.withOpacity(0.5) : bgColor.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? bgColor.withOpacity(1) : Colors.transparent,
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            // For tag chips (not 'All'), show the tag colour as text colour
            color: uuid == null
                ? Colors.black87
                : bgColor.withOpacity(selected ? 1 : 0.7),
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    final n = d;
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[n.weekday - 1]}, ${n.day} ${m[n.month-1]}';
  }
}