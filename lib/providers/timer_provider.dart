import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
        FlutterLocalNotificationsPlugin().show(
          999,
          'Pomodoro Finished!',
          'Time for a break 🎉',
          const NotificationDetails(
              android: AndroidNotificationDetails('pomodoro', 'Pomodoro')),
        );
      }
    });
  }

  void pause() => _timer?.cancel();
  void reset() {
    _timer?.cancel();
    state = duration;
  }
}
