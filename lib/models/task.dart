import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  final String uuid;

  @HiveField(2)
  String title;

  @HiveField(3)
  String description;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  String category;

  @HiveField(7)
  int priority;

  @HiveField(8)
  int pomodoros;

  Task({
    this.id,
    required this.uuid,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.dueDate,
    required this.category,
    required this.priority,
    this.pomodoros = 0,
  });
}
