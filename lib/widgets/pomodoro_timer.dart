import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_provider.dart';
import '../providers/task_providers.dart';

import '../models/task.dart';

class PomodoroTimerWidget extends ConsumerWidget {
  const PomodoroTimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seconds = ref.watch(pomodoroTimerProvider);
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Pomodoro Timer',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('$minutes:$secs',
                style:
                    const TextStyle(fontSize: 56, fontWeight: FontWeight.w300)),
            const SizedBox(height: 12),
            // Active task selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Consumer(
                builder: (context, ref2, _) {
                  final tasksAsync = ref2.watch(tasksProvider);
                  final active = ref2.watch(activeTaskProvider);
                  return tasksAsync.when(
                    data: (tasks) {
                      final items = <DropdownMenuItem<String?>>[
                        const DropdownMenuItem(
                            value: null, child: Text('None')),
                        ...tasks.map((Task t) => DropdownMenuItem(
                            value: t.uuid, child: Text(t.title)))
                      ];
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          isExpanded: true,
                          value: active,
                          items: items,
                          onChanged: (v) =>
                              ref2.read(activeTaskProvider.notifier).set(v),
                        ),
                      );
                    },
                    loading: () => const SizedBox(
                        height: 40,
                        child: Center(child: CircularProgressIndicator())),
                    error: (_, __) => const Text('Failed to load tasks'),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () =>
                        ref.read(pomodoroTimerProvider.notifier).start(),
                    child: const Text('Start')),
                ElevatedButton(
                    onPressed: () =>
                        ref.read(pomodoroTimerProvider.notifier).pause(),
                    child: const Text('Pause')),
                ElevatedButton(
                    onPressed: () =>
                        ref.read(pomodoroTimerProvider.notifier).reset(),
                    child: const Text('Reset')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
