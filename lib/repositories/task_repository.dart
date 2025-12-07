import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  throw UnimplementedError(
      'taskRepositoryProvider must be initialized via override');
});

class TaskRepository {
  final Box<Task> _box;

  TaskRepository(this._box);

  Future<List<Task>> getTasks() async {
    return _box.values.toList();
  }

  Future<void> addTask(Task task) async {
    await _box.add(task);
    await task.save();
  }

  Future<void> updateTask(Task task) async {
    await task.save();
  }

  Future<void> deleteTask(Task task) async {
    await task.delete();
  }

  Future<List<Task>> search({
    required String query,
    String? category,
    int? priority,
  }) async {
    var tasks = _box.values.toList();

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      tasks = tasks
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              t.description.toLowerCase().contains(q))
          .toList();
    }

    if (category != null && category != 'All') {
      tasks = tasks.where((t) => t.category == category).toList();
    }

    if (priority != null) {
      tasks = tasks.where((t) => t.priority == priority).toList();
    }

    return tasks;
  }

  Future<int> completedCount() async {
    return _box.values.where((t) => t.isCompleted).length;
  }

  Future<int> totalCount() async {
    return _box.length;
  }
}
