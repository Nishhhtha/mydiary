import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/tag.dart';
import '../providers/task_provider.dart';
import '../web_storage_service.dart';

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
  bool       _creatingTag= false;
  
  final Set<int> _selectedDays = {};
  static const List<String> _dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(allTagsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(
        'Add Task',
        style: TextStyle(
        color: Color(0xFFFAFAFA), // Applying the hex color here
        ),
        ),
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
              _label('Tag'),
              if (!_creatingTag) ...[
                Wrap(spacing: 8, runSpacing: 8, children: [
                  ...tags.map((t) => GestureDetector(
                    onTap: () => setState(() => _selectedTag = t),
                    onLongPress: () => _confirmDeleteTag(context, t),  // ← Fix 2 added here
                    child: Chip(
                      label: Text(
                        t.name,
                        style: TextStyle(
                          // Show tag colour as text colour
                          color: _selectedTag?.uuid == t.uuid
                              ? t.color
                              : t.color.withOpacity(0.75),
                          fontWeight: _selectedTag?.uuid == t.uuid
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      // Always show tag colour as background
                      backgroundColor: _selectedTag?.uuid == t.uuid
                          ? t.color.withOpacity(0.3)
                          : t.color.withOpacity(0.12),
                      side: BorderSide(
                        color: _selectedTag?.uuid == t.uuid
                            ? t.color.withOpacity(0.8)
                            : t.color.withOpacity(0.3),
                        width: 1.5,
                      ),
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (final c in [Colors.yellowAccent, Colors.amber, Colors.orange, 
                        Colors.red, Colors.pink.shade300, Colors.pink, Colors.pink.shade900, 
                        Colors.lime, Colors.lightGreen, Colors.green, Colors.teal, Colors.cyan, 
                        Colors.blue, Colors.indigo, Colors.purple, Colors.deepPurple])
                      GestureDetector(
                        onTap: () => setState(() => _newTagColor = c),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: c.withOpacity(0.5),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _newTagColor == c ? Colors.black : Colors.transparent,
                                width: 3),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
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
              _label('Activity'),
              _field(_titleCtrl, 'e.g. Morning Walk, English Essay'),
              const SizedBox(height: 16),

              // ── Description ──────────────────────────────────────────
              _label('Description (optional)'),
              _field(_descCtrl, 'Any extra notes', maxLines: 2),
              const SizedBox(height: 16),

              // ── Metric type ──────────────────────────────────────────
              _label('Metric'),
              Row(children: [
                Radio<MetricType>(value: MetricType.boolean, groupValue: _metricType,
                    onChanged: (v) => setState(() => _metricType = v!)),
                const Expanded(child: Text('Checkbox')),
                Radio<MetricType>(value: MetricType.numeric, groupValue: _metricType,
                    onChanged: (v) => setState(() => _metricType = v!)),
                const Expanded(child: Text('Count')),
              ]),
              if (_metricType == MetricType.numeric) ...[
                _label('Unit'),
                const SizedBox(height: 8),
                // NEW: Predefined unit options
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (final unit in ['steps', 'km', 'kg', 'm', 'custom'])
                      GestureDetector(
                        onTap: () {
                          if (unit == 'custom') {
                            _metricUnitCtrl.clear();
                          } else {
                            _metricUnitCtrl.text = unit;
                          }
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (_metricUnitCtrl.text == unit || (unit == 'custom' && _metricUnitCtrl.text.isEmpty))
                                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: (_metricUnitCtrl.text == unit || (unit == 'custom' && _metricUnitCtrl.text.isEmpty))
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              unit == 'custom' ? 'Custom' : unit,
                              style: TextStyle(
                                fontWeight: (_metricUnitCtrl.text == unit || (unit == 'custom' && _metricUnitCtrl.text.isEmpty))
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
                const SizedBox(height: 12),
                _field(_metricUnitCtrl, 'Custom unit'),
                const SizedBox(height: 8),
                _label('Daily Target'),
                _field(_metricTargetCtrl, 'e.g. 10000',
                    keyboard: const TextInputType.numberWithOptions(decimal: true)),
              ],
              const SizedBox(height: 16),

              // ── Date rule ────────────────────────────────────────────
              _label('Date'),
              DropdownButtonFormField<DateRule>(
                value: _dateRule,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: DateRule.everyday,     child: Text('Every day')),
                  DropdownMenuItem(value: DateRule.specificDate, child: Text('Date')),
                  DropdownMenuItem(value: DateRule.deadline,     child: Text('Deadline')),
                  DropdownMenuItem(value: DateRule.specificDays, child: Text('Repeat')),
                ],
                onChanged: (v) => setState(() {
                  _dateRule = v!;
                  if (v == DateRule.specificDays) {
                    _selectedDays.clear();
                  }
                }),
              ),
              if (_dateRule == DateRule.specificDate || _dateRule == DateRule.deadline)
                _datePicker('Start Date', _startDate,
                    (d) => setState(() => _startDate = d)),
              if (_dateRule == DateRule.deadline)
                _datePicker('Due Date (Deadline)', _endDate,
                    (d) => setState(() => _endDate = d)),
              
              if (_dateRule == DateRule.specificDays) ...[
                const SizedBox(height: 16),
                _label('Select Days'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(7, (index) {
                    final dayNum = index + 1;
                    final isSelected = _selectedDays.contains(dayNum);
                    return FilterChip(
                      label: Text(_dayNames[index]),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(dayNum);
                          } else {
                            _selectedDays.remove(dayNum);
                          }
                        });
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      side: BorderSide(
                        color: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),
              ],
              const SizedBox(height: 32),

              // ── Save button ──────────────────────────────────────────
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBADFDB),  // ← your soft teal
                    foregroundColor: const Color(0xFF3D3D3D),  // dark text (not white)
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
        hintText: hint, 
        border: const OutlineInputBorder(),
        filled: true, 
        fillColor: Colors.grey.shade50,
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
    final tag = Tag(
      uuid : _uuid.v4(),
      name : _newTagNameCtrl.text.trim(),
      colorHex : _newTagColor.value.toRadixString(16).padLeft(8, '0').toUpperCase(),
      order : 0,
    );
    await TaskService.saveTag(tag,ref);
    setState(() {
      _selectedTag = tag;
      _creatingTag = false;
      _newTagNameCtrl.clear();
    });
  }

  void _confirmDeleteTag(BuildContext context, Tag tag) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete Tag?'),
      content: Text(
        'Delete the tag "${tag.name}"?\n\nTasks using this tag will not be deleted — they will just lose their tag colour.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            Navigator.pop(context);
            await WebStorageService.deleteTag(tag.uuid);
            await ref.read(allTagsProvider.notifier).refresh();
            if (_selectedTag?.uuid == tag.uuid) {
              setState(() => _selectedTag = null);
            }
          },
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

  Future<void> _save() async {
  if (_titleCtrl.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter an activity name')));
    return;
  }
  if (_dateRule == DateRule.specificDays && _selectedDays.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select at least one day of the week')));
    return;
  }
  setState(() => _saving = true);
  final task = Task(                        // ← named constructor, not cascade
    uuid:          _uuid.v4(),
    title:         _titleCtrl.text.trim(),
    description:   _descCtrl.text.trim(),
    tagUuid:       _selectedTag?.uuid ?? 'general',
    metricType:    _metricType,
    metricUnit:    _metricType == MetricType.numeric ? _metricUnitCtrl.text.trim() : null,
    metricTarget:  _metricType == MetricType.numeric
                     ? (double.tryParse(_metricTargetCtrl.text) ?? 1.0) : 1.0,
    dateRule:      _dateRule,
    startDate:     _startDate,
    endDate:       _endDate,
    currentStreak: 0,
    specificDays:  _selectedDays.toList(),
  );
  await TaskService.saveTask(task, ref);    // ← add ref
  setState(() => _saving = false);
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Task saved!')));
    _titleCtrl.clear(); _descCtrl.clear();
    _metricUnitCtrl.clear(); _metricTargetCtrl.text = '1';
    setState(() {
      _selectedTag = null;
      _dateRule = DateRule.everyday;
      _selectedDays.clear();
    });
  }
}
}