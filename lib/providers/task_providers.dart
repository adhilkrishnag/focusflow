import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';
import '../repositories/task_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notifications.dart';

final tasksProvider = AsyncNotifierProvider<Tasks, List<Task>>(Tasks.new);

class Tasks extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() => ref.read(taskRepositoryProvider).getTasks();

  Future<void> add(Task task) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(taskRepositoryProvider).addTask(task);
      if (task.dueDate != null) _schedule(task);
      return ref.read(taskRepositoryProvider).getTasks();
    });
  }

  Future<void> updateTask(Task task) async {
    await ref.read(taskRepositoryProvider).updateTask(task);
    ref.invalidateSelf();
  }

  Future<void> toggle(String uuid) async {
    final task = (state.value ?? []).firstWhere((t) => t.uuid == uuid);
    task.isCompleted = !task.isCompleted;
    await ref.read(taskRepositoryProvider).updateTask(task);
    ref.invalidateSelf();
  }

  Future<void> delete(String uuid) async {
    final task = (state.value ?? []).firstWhere((t) => t.uuid == uuid);
    await ref.read(taskRepositoryProvider).deleteTask(task);
    ref.invalidateSelf();
  }

  void _schedule(Task task) async {
    final notif = flutterLocalNotificationsPlugin;
    final due = task.dueDate!;
    if (due.isBefore(DateTime.now())) return;

    // Use hashcode of uuid for ID since Hive id might be null before save?
    // Actually HiveObject key is dynamic.
    // Task.id is manageable if we manually set it or trust Hive key.
    // For notification ID we need int.
    // task.key should be int if we use AutoIncrement box?
    // Let's use task.key as int if available, or hash of uuid.
    int notifId = task.key is int ? task.key as int : task.uuid.hashCode;

    await notif.zonedSchedule(
      notifId,
      'Task Due: ${task.title}',
      'Due ${DateFormat.yMMMd().add_jm().format(due)}',
      tz.TZDateTime.from(due, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails('tasks', 'Tasks',
            importance: Importance.high, priority: Priority.high),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

final activeTaskProvider =
    NotifierProvider<ActiveTask, String?>(ActiveTask.new);

class ActiveTask extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? uuid) => state = uuid;
}

final completedPercentageProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(taskRepositoryProvider);
  final completed = await repo.completedCount();
  final total = await repo.totalCount();
  return total == 0 ? 0 : ((completed / total) * 100).round();
});

final searchQueryProvider =
    NotifierProvider<SearchQuery, String>(SearchQuery.new);

class SearchQuery extends Notifier<String> {
  @override
  String build() => '';
  void set(String q) => state = q;
}

final categoryFilterProvider =
    NotifierProvider<CategoryFilter, String?>(CategoryFilter.new);

class CategoryFilter extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? c) => state = c;
}

final priorityFilterProvider =
    NotifierProvider<PriorityFilter, int?>(PriorityFilter.new);

class PriorityFilter extends Notifier<int?> {
  @override
  int? build() => null;
  void set(int? p) => state = p;
}

final filteredTasksProvider = FutureProvider<List<Task>>((ref) async {
  final q = ref.watch(searchQueryProvider);
  final c = ref.watch(categoryFilterProvider);
  final p = ref.watch(priorityFilterProvider);
  ref.watch(tasksProvider);

  return ref
      .read(taskRepositoryProvider)
      .search(query: q, category: c, priority: p);
});
