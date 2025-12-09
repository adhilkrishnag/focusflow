import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../providers/task_providers.dart';
import '../repositories/task_repository.dart';
import '../services/notifications.dart';

final pomodoroTimerProvider =
    NotifierProvider<PomodoroTimer, int>(PomodoroTimer.new);

class PomodoroTimer extends Notifier<int> {
  Timer? _timer;
  static const int duration = 25 * 60;

  @override
  int build() => duration;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state > 0) {
        state--;
      } else {
        _timer?.cancel();
        _onFinished();
      }
    });
  }

  Future<void> _onFinished() async {
    await flutterLocalNotificationsPlugin.show(
      999,
      'Pomodoro Finished!',
      'Time for a break 🎉',
      const NotificationDetails(
          android: AndroidNotificationDetails('pomodoro', 'Pomodoro')),
    );

    // If there's an active task, increment its pomodoro count and persist
    final activeUuid = ref.read(activeTaskProvider);
    if (activeUuid != null) {
      try {
        final repo = ref.read(taskRepositoryProvider);
        final tasks = await repo.getTasks();
        final task = tasks.firstWhere((t) => t.uuid == activeUuid);
        task.pomodoros = task.pomodoros + 1;
        await repo.updateTask(task);
        // Update cached provider state
        ref.read(tasksProvider.notifier).updateTask(task);
      } catch (_) {
        // ignore if task not found
      }
    }
  }

  void pause() => _timer?.cancel();
  void reset() {
    _timer?.cancel();
    state = duration;
  }
}
