import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../providers/task_providers.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final Task? existingTask;
  const AddTaskScreen({super.key, this.existingTask});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  DateTime? _dueDate;
  String _category = 'General';
  int _priority = 1;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existingTask?.title ?? '');
    _descCtrl =
        TextEditingController(text: widget.existingTask?.description ?? '');
    _dueDate = widget.existingTask?.dueDate;
    _category = widget.existingTask?.category ?? 'General';
    _priority = widget.existingTask?.priority ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTask == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title *'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_dueDate == null
                    ? 'Set Due Date'
                    : DateFormat.yMMMd().add_jm().format(_dueDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    if (!context.mounted) return;
                    final time = await showTimePicker(
                        context: context, initialTime: TimeOfDay.now());
                    if (time != null && mounted) {
                      setState(() => _dueDate = DateTime(picked.year,
                          picked.month, picked.day, time.hour, time.minute));
                    }
                  }
                },
              ),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['General', 'Work', 'Personal']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                // ignore: deprecated_member_use
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: [
                  const DropdownMenuItem(value: 0, child: Text('Low')),
                  const DropdownMenuItem(value: 1, child: Text('Medium')),
                  const DropdownMenuItem(value: 2, child: Text('High')),
                ],
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final task = widget.existingTask ??
                        Task(
                          uuid: const Uuid().v4(),
                          title: '',
                          description: '',
                          category: 'General',
                          priority: 1,
                        );

                    task
                      ..title = _titleCtrl.text
                      ..description = _descCtrl.text
                      ..dueDate = _dueDate
                      ..category = _category
                      ..priority = _priority;

                    if (widget.existingTask == null) {
                      ref.read(tasksProvider.notifier).add(task);
                    } else {
                      ref.read(tasksProvider.notifier).updateTask(task);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.existingTask == null
                    ? 'Create Task'
                    : 'Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
