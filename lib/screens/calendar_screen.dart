import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focused  = DateTime.now();
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(allTasksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,_) => Center(child: Text('Error: $e')),
        data: (tasks) => TableCalendar<Task>(
          firstDay: DateTime(2024), lastDay: DateTime(2030),
          focusedDay: _focused,
          selectedDayPredicate: (d) => isSameDay(_selected, d),
          onDaySelected: (sel, foc) =>
              setState(() { _selected = sel; _focused = foc; }),
          eventLoader: (day) =>
              tasks.where((t) => taskAppearsOn(t, day)).toList(),
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        ),
      ),
    );
  }
}
