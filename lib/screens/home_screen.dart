import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_providers.dart';
import '../providers/theme_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/pomodoro_timer.dart';
import 'add_task_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(filteredTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusFlow', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
          ),
          IconButton(
            icon: Icon(ref.watch(themeModeNotifierProvider) == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeModeNotifierProvider.notifier).toggle(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + Filters
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search tasks',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => ref.read(searchQueryProvider.notifier).set(v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: ref.watch(categoryFilterProvider),
                      hint: const Text('Category'),
                      isExpanded: true,
                      items: [null, 'General', 'Work', 'Personal']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e ?? 'All')))
                          .toList(),
                      onChanged: (v) => ref.read(categoryFilterProvider.notifier).set(v),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: ref.watch(priorityFilterProvider),
                      hint: const Text('Priority'),
                      isExpanded: true,
                      items: [null, 0, 1, 2]
                          .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e == null ? 'All' : e == 0 ? 'Low' : e == 1 ? 'Medium' : 'High')))
                          .toList(),
                      onChanged: (v) => ref.read(priorityFilterProvider.notifier).set(v),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const PomodoroTimerWidget(),

          // Task List
          Expanded(
            child: tasksAsync.when(
              data: (tasks) => tasks.isEmpty
                  ? const Center(child: Text('No tasks yet. Add one!'))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, i) => PageTransitionSwitcher(
                        transitionBuilder: (child, a1, a2) => FadeThroughTransition(animation: a1, secondaryAnimation: a2, child: child),
                        child: TaskCard(key: ValueKey(tasks[i].uuid), task: tasks[i]),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Error loading tasks')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTaskScreen())),
      ),
    );
  }
}