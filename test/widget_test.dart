import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_flow/main.dart';
import 'package:focus_flow/models/task.dart';
import 'package:focus_flow/repositories/task_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Fake Repository
class FakeTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getTasks() async => _tasks;

  @override
  Future<void> addTask(Task task) async => _tasks.add(task);

  @override
  Future<void> updateTask(Task task) async {}

  @override
  Future<void> deleteTask(Task task) async => _tasks.remove(task);

  @override
  Future<List<Task>> search(
      {required String query, String? category, int? priority}) async {
    return _tasks;
  }

  @override
  Future<int> completedCount() async =>
      _tasks.where((t) => t.isCompleted).length;

  @override
  Future<int> totalCount() async => _tasks.length;
}

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(sharedPrefs),
          taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify layout
    expect(find.text('FocusFlow'), findsOneWidget); // App Bar title
    expect(find.byType(FloatingActionButton), findsOneWidget); // Add button
  });
}
