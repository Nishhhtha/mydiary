import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/tag.dart';
import '../providers/task_provider.dart';

const _uuid = Uuid();

class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key});
  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _titleCtrl       = TextEditingController();
  final _descCtrl        = TextEditingController();
  final _metricUnitCtrl  = TextEditingController();
  final _metricTargetCtrl= TextEditingController(text: '1');
  final _newTagNameCtrl  = TextEditingController();

  MetricType _metricType = MetricType.boolean;
  DateRule   _dateRule   = DateRule.everyday;
  DateTime   _startDate  = DateTime.now();
  DateTime?  _endDate;
  Tag?       _selectedTag;
  Color      _newTagColor = const Color(0xFF4CAF50);
  bool       _saving     = false;
  bool       _creatingTag= false; // Toggle: show existing tags or create new

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(allTagsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Task'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: tagsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,_) => Center(child: Text('Error: $e')),
        data: (tags) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Tag section ──────────────────────────────────────────
              _label('Tag (Category)'),
              if (!_creatingTag) ...[
                Wrap(spacing: 8, runSpacing: 8, children: [
                  ...tags.map((t) => GestureDetector(
                    onTap: () => setState(() => _selectedTag = t),
                    child: Chip(
                      label: Text(t.name),
                      backgroundColor: _selectedTag?.uuid == t.uuid
                          ? t.color.withOpacity(0.4) : null,
                      side: BorderSide(
                        color: _selectedTag?.uuid == t.uuid ? Colors.black38 : Colors.grey.shade300),
                    ),
                  )),
                  ActionChip(
                    label: const Text('+ New Tag'),
                    onPressed: () => setState(() => _creatingTag = true),
                  ),
                ]),
              ] else ...[
                _field(_newTagNameCtrl, 'Tag name, e.g. Exercise'),
                const SizedBox(height: 8),
                // Simple colour picker row
                Wrap(spacing: 8, children: [
                  for (final c in [Colors.green, Colors.blue, Colors.pink,
                      Colors.orange, Colors.purple, Colors.teal,
                      Colors.red, Colors.amber])
                    GestureDetector(
                      onTap: () => setState(() => _newTagColor = c),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: c, shape: BoxShape.circle,
                          border: Border.all(
                            color: _newTagColor == c ? Colors.black : Colors.transparent,
                            width: 3),
                        ),
                      ),
                    ),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  ElevatedButton(onPressed: _saveTag, child: const Text('Save Tag')),
                  const SizedBox(width: 12),
                  TextButton(onPressed: () => setState(() => _creatingTag = false),
                      child: const Text('Cancel')),
                ]),
              ],
              const SizedBox(height: 20),

              // ── Activity name ────────────────────────────────────────
              _label('Activity Name'),
              _field(_titleCtrl, 'e.g. Morning Walk, English Essay'),
              const SizedBox(height: 16),

              // ── Description ──────────────────────────────────────────
              _label('Description (optional)'),
              _field(_descCtrl, 'Any extra notes', maxLines: 2),
              const SizedBox(height: 16),

              // ── Metric type ──────────────────────────────────────────
              _label('Metric Type'),
              Row(children: [
                Radio<MetricType>(value: MetricType.boolean, groupValue: _metricType,
                    onChanged: (v) => setState(() => _metricType = v!)),
                const Text('Checkbox'),
                const SizedBox(width: 20),
                Radio<MetricType>(value: MetricType.numeric, groupValue: _metricType,
                    onChanged: (v) => setState(() => _metricType = v!)),
                const Text('Track a number'),
              ]),
              if (_metricType == MetricType.numeric) ...[
                _label('Unit (e.g. steps, km, kg)'),
                _field(_metricUnitCtrl, 'e.g. steps'),
                const SizedBox(height: 8),
                _label('Daily Target'),
                _field(_metricTargetCtrl, 'e.g. 10000',
                    keyboard: const TextInputType.numberWithOptions(decimal: true)),
              ],
              const SizedBox(height: 16),

              // ── Date rule ────────────────────────────────────────────
              _label('When should this task appear?'),
              DropdownButtonFormField<DateRule>(
                value: _dateRule,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: DateRule.everyday,     child: Text('Every day')),
                  DropdownMenuItem(value: DateRule.specificDate, child: Text('One specific date')),
                  DropdownMenuItem(value: DateRule.deadline,     child: Text('Has a deadline — shows daily until done')),
                  DropdownMenuItem(value: DateRule.specificDays, child: Text('Specific days of the week')),
                ],
                onChanged: (v) => setState(() => _dateRule = v!),
              ),
              if (_dateRule == DateRule.specificDate || _dateRule == DateRule.deadline)
                _datePicker('Start Date', _startDate,
                    (d) => setState(() => _startDate = d)),
              if (_dateRule == DateRule.deadline)
                _datePicker('Due Date (Deadline)', _endDate,
                    (d) => setState(() => _endDate = d)),
              const SizedBox(height: 32),

              // ── Save button ──────────────────────────────────────────
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Task', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 4),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
  );

  Widget _field(TextEditingController c, String hint,
      {int maxLines=1, TextInputType keyboard=TextInputType.text}) =>
    TextField(
      controller: c, maxLines: maxLines, keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint, border: const OutlineInputBorder(),
        filled: true, fillColor: Colors.grey.shade50,
      ),
    );

  Widget _datePicker(String label, DateTime? current, Function(DateTime) onPick) =>
    ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(current != null
          ? '${current.day}/${current.month}/${current.year}' : 'Tap to select a date'),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: current ?? DateTime.now(),
          firstDate: DateTime(2024), lastDate: DateTime(2030),
        );
        if (picked != null) onPick(picked);
      },
    );

  Future<void> _saveTag() async {
    if (_newTagNameCtrl.text.trim().isEmpty) return;
    final tag = Tag()
      ..uuid = _uuid.v4()
      ..name = _newTagNameCtrl.text.trim()
      ..colorHex = _newTagColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()
      ..order = 0;
    await TaskService.saveTag(tag);
    setState(() {
      _selectedTag = tag;
      _creatingTag = false;
      _newTagNameCtrl.clear();
    });
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an activity name')));
      return;
    }
    setState(() => _saving = true);
    final task = Task()
      ..uuid        = _uuid.v4()
      ..title       = _titleCtrl.text.trim()
      ..description = _descCtrl.text.trim()
      ..tagUuid     = _selectedTag?.uuid ?? 'general'
      ..metricType  = _metricType
      ..metricUnit  = _metricType == MetricType.numeric ? _metricUnitCtrl.text.trim() : null
      ..metricTarget= _metricType == MetricType.numeric
                        ? (double.tryParse(_metricTargetCtrl.text) ?? 1.0) : 1.0
      ..dateRule    = _dateRule
      ..startDate   = _startDate
      ..endDate     = _endDate
      ..currentStreak = 0
      ..specificDays  = [];
    await TaskService.saveTask(task);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('\u2705 Task saved!')));
      _titleCtrl.clear(); _descCtrl.clear();
      _metricUnitCtrl.clear(); _metricTargetCtrl.text = '1';
      setState(() { _selectedTag = null; _dateRule = DateRule.everyday; });
    }
  }
}
