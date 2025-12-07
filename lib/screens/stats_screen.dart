import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percentageAsync = ref.watch(completedPercentageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Center(
        child: percentageAsync.when(
          data: (percent) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$percent%',
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
              ),
              const Text('Tasks Completed', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 40),
              const Icon(Icons.trending_up, size: 80, color: Colors.green),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text('Error loading stats'),
        ),
      ),
    );
  }
}