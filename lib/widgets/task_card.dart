import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  Color _priorityColor(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.low => Colors.green,
      TaskPriority.medium => Colors.orange,
      TaskPriority.high => Colors.red,
    };
  }

  IconData _categoryIcon(TaskCategory category) {
    return switch (category) {
      TaskCategory.personal => Icons.person,
      TaskCategory.work => Icons.work,
      TaskCategory.study => Icons.school,
      TaskCategory.health => Icons.favorite,
      TaskCategory.other => Icons.more_horiz,
    };
  }

  Color _statusColor(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => Colors.grey,
      TaskStatus.inProgress => Colors.blue,
      TaskStatus.completed => Colors.green,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTaskDetail(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => ref.read(taskProvider.notifier).toggleStatus(task.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.status == TaskStatus.completed
                        ? Colors.green
                        : Colors.transparent,
                    border: Border.all(
                      color: _statusColor(task.status),
                      width: 2.5,
                    ),
                  ),
                  child: task.status == TaskStatus.completed
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : task.status == TaskStatus.inProgress
                          ? const Icon(Icons.hourglass_top, size: 16, color: Colors.blue)
                          : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.status == TaskStatus.completed
                            ? Colors.grey
                            : null,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(_categoryIcon(task.category), size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          task.category.name[0].toUpperCase() + task.category.name.substring(1),
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _priorityColor(task.priority).withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.priority.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _priorityColor(task.priority),
                            ),
                          ),
                        ),
                        if (task.dueDate != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            '${task.dueDate!.day}/${task.dueDate!.month}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditDialog(context, ref);
                  } else if (value == 'delete') {
                    ref.read(taskProvider.notifier).deleteTask(task.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetail(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(task.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(_categoryIcon(task.category), task.category.name),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.flag, task.priority.name),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.circle, task.status.name),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(task.description, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            ],
            if (task.dueDate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 8),
                  Text('Vence: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text('Creada: ${task.createdAt.day}/${task.createdAt.month}/${task.createdAt.year}',
                style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController(text: task.title);
    final descCtrl = TextEditingController(text: task.description);
    var category = task.category;
    var priority = task.priority;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Editar tarea'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                DropdownButtonFormField<TaskCategory>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: TaskCategory.values.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name[0].toUpperCase() + c.name.substring(1)),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => category = v!),
                ),
                DropdownButtonFormField<TaskPriority>(
                  value: priority,
                  decoration: const InputDecoration(labelText: 'Prioridad'),
                  items: TaskPriority.values.map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(p.name[0].toUpperCase() + p.name.substring(1)),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => priority = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                ref.read(taskProvider.notifier).updateTask(
                  task.copyWith(
                    title: titleCtrl.text,
                    description: descCtrl.text,
                    category: category,
                    priority: priority,
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
