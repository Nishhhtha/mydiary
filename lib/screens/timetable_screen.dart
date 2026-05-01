import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../isar_service.dart';
import '../models/time_block.dart';

const _uuid = Uuid();
const double _hourHeight = 64.0; // pixel height of one hour row
const double _timeColW   = 56.0; // width of the left time label column

// Converts a DateTime's time to minutes-from-midnight
int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

// Returns today's date string YYYY-MM-DD
String _ds(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});
  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  DateTime _viewDate = DateTime.now(); // Which day the user is viewing
  List<TimeBlock> _blocks = [];
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadBlocks();
    // Scroll to 7 AM on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          7 * _hourHeight,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadBlocks() async {
    final blocks = await IsarService.db.timeBlocks
        .filter()
        .dateEqualTo(_ds(_viewDate))
        .findAll();
    blocks.sort((a, b) => a.startMinute.compareTo(b.startMinute));
    if (mounted) setState(() => _blocks = blocks);
  }

  // Called when user changes day (prev/next arrows)
  void _changeDay(int delta) {
    setState(() {
      _viewDate = _viewDate.add(Duration(days: delta));
      _blocks = [];
    });
    _loadBlocks();
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _ds(_viewDate) == _ds(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Previous day arrow
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeDay(-1),
          ),
          // Day label
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _viewDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() { _viewDate = picked; _blocks = []; });
                _loadBlocks();
              }
            },
            child: Text(
              isToday ? 'Today — ${_fmtDate(_viewDate)}' : _fmtDate(_viewDate),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          // Next day arrow
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeDay(1),
          ),
        ]),
      ),
      // FAB to add a new block
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Block'),
      ),
      body: SingleChildScrollView(
        controller: _scrollCtrl,
        child: SizedBox(
          // Total height = 24 hours x pixels per hour
          height: 24 * _hourHeight,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Left column: hour labels (00:00 … 23:00) ───────────────
            SizedBox(
              width: _timeColW,
              child: Stack(
                children: List.generate(24, (h) => Positioned(
                  top: h * _hourHeight - 8, // -8 to vertically centre label
                  left: 0, right: 0,
                  child: Text(
                    h == 0 ? '' : '${h.toString().padLeft(2,'0')}:00',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 11,
                        color: Colors.grey.shade500),
                  ),
                )),
              ),
            ),

            // ── Right column: hour grid lines + blocks ──────────────────
            Expanded(
              child: Stack(children: [

                // Hour divider lines
                ...List.generate(24, (h) => Positioned(
                  top: h * _hourHeight,
                  left: 0, right: 0,
                  child: Divider(
                    height: 1, thickness: 0.5,
                    color: h % 6 == 0
                        ? Colors.grey.shade400   // darker every 6 hours
                        : Colors.grey.shade200,
                  ),
                )),

                // 'Now' indicator line (only on today)
                if (isToday) _nowIndicator(),

                // Time blocks
                ..._blocks.map((block) => _blockWidget(context, block)),

              ]),
            ),
            const SizedBox(width: 8),
          ]),
        ),
      ),
    );
  }

  // The red 'current time' line, like Google Calendar
  Widget _nowIndicator() {
    final now = DateTime.now();
    final top = (now.hour * 60 + now.minute) * (_hourHeight / 60);
    return Positioned(
      top: top,
      left: 0, right: 0,
      child: Row(children: [
        Container(width: 10, height: 10,
            decoration: const BoxDecoration(
              color: Colors.red, shape: BoxShape.circle)),
        Expanded(child: Container(height: 2, color: Colors.red)),
      ]),
    );
  }

  // A single positioned time block card
  Widget _blockWidget(BuildContext context, TimeBlock block) {
    final top    = block.startMinute * (_hourHeight / 60);
    final height = block.durationMinutes * (_hourHeight / 60);
    final color  = Color(int.parse(block.colorHex, radix: 16));

    return Positioned(
      top: top,
      left: 4, right: 4,
      height: height.clamp(24.0, double.infinity),
      child: GestureDetector(
        // Long-press to delete
        onLongPress: () => _confirmDelete(context, block),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.25),
            borderRadius: BorderRadius.circular(6),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(block.label,
                  style: TextStyle(fontWeight: FontWeight.bold,
                      fontSize: height < 32 ? 11 : 13,
                      color: color.withOpacity(0.9)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              if (height >= 36)
                Text('${block.startLabel} – ${block.endLabel}',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                    maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }

  // Delete confirmation dialog
  void _confirmDelete(BuildContext context, TimeBlock block) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Block?'),
        content: Text('Delete "${block.label}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await IsarService.db.writeTxn(() async {
                await IsarService.db.timeBlocks.delete(block.id);
              });
              _loadBlocks(); // Refresh the view
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Add block dialog with time pickers and colour picker
  void _showAddDialog(BuildContext context) {
    final labelCtrl = TextEditingController();
    TimeOfDay start = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay end   = const TimeOfDay(hour: 10, minute: 0);
    Color selectedColor = const Color(0xFF0D9488);

    // The colours available to pick for a block
    final colors = [
      const Color(0xFF0D9488), // teal
      const Color(0xFF1D4ED8), // blue
      const Color(0xFF15803D), // green
      const Color(0xFFEA580C), // orange
      const Color(0xFF7C3AED), // purple
      const Color(0xFFDC2626), // red
      const Color(0xFFCA8A04), // yellow
      const Color(0xFFDB2777), // pink
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Add Time Block'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Label field
                TextField(
                  controller: labelCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    hintText: 'e.g. Study, Gym, Lunch',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Start + End time
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text('Start: ${start.format(ctx)}'),
                    onPressed: () async {
                      final t = await showTimePicker(
                          context: ctx, initialTime: start);
                      if (t != null) setD(() => start = t);
                    },
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time_filled, size: 16),
                    label: Text('End: ${end.format(ctx)}'),
                    onPressed: () async {
                      final t = await showTimePicker(
                          context: ctx, initialTime: end);
                      if (t != null) setD(() => end = t);
                    },
                  )),
                ]),
                const SizedBox(height: 16),

                // Colour picker row
                const Text('Colour', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: colors.map((c) => GestureDetector(
                  onTap: () => setD(() => selectedColor = c),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: c, shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColor == c
                            ? Colors.black : Colors.transparent,
                        width: 3),
                    ),
                  ),
                )).toList()),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (labelCtrl.text.trim().isEmpty) return;
                final startMin = _toMinutes(start);
                final endMin   = _toMinutes(end);
                if (endMin <= startMin) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('End time must be after start time')));
                  return;
                }
                final block = TimeBlock()
                  ..uuid        = _uuid.v4()
                  ..label       = labelCtrl.text.trim()
                  ..date        = _ds(_viewDate)
                  ..startMinute = startMin
                  ..endMinute   = endMin
                  ..colorHex    = selectedColor.value
                      .toRadixString(16).padLeft(8,'0').toUpperCase();
                await IsarService.db.writeTxn(() async {
                  await IsarService.db.timeBlocks.put(block);
                });
                Navigator.pop(ctx);
                _loadBlocks(); // Reload and re-sort
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${days[d.weekday-1]}, ${d.day} ${months[d.month-1]}';
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }
}
