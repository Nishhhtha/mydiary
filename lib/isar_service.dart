
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/task.dart';
import 'models/tag.dart';
import 'models/task_log.dart';
import 'models/time_block.dart'; // <-- NEW

class IsarService {
  static Isar? _isar;

  static Future<void> init() async {
    if (_isar != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [TaskSchema, TagSchema, TaskLogSchema, TimeBlockSchema], // <-- added TimeBlockSchema
      directory: dir.path,
    );
  }

  static Isar get db {
    if (_isar == null) throw Exception('Isar not initialised');
    return _isar!;
  }
}
