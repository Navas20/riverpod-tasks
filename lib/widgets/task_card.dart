import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  Color _priorityColor(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.low => const Color(0xFF10B981),
      TaskPriority.medium => const Color(0xFFF59E0B),
      TaskPriority.high => const Color(0xFFEF4444),
    };
  }

  IconData _categoryIcon(TaskCategory category) {
    return switch (category) {
      TaskCategory.personal => Icons.person_rounded,
      TaskCategory.work => Icons.work_rounded,
      TaskCategory.study => Icons.school_rounded,
      TaskCategory.health => Icons.favorite_rounded,
      TaskCategory.other => Icons.more_horiz_rounded,
    };
  }

  Color? _statusColor(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => null,
      TaskStatus.inProgress => const Color(0xFF8B5CF6),
      TaskStatus.completed => const Color(0xFF10B981),
    };
  }

  String _categoryLabel(TaskCategory category) {
    return category.name[0].toUpperCase() + category.name.substring(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isCompleted = task.status == TaskStatus.completed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
          _showTaskDetail(context, ref);
        },
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 150),
          tween: Tween(begin: 1, end: 1),
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(taskProvider.notifier).toggleStatus(task.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isCompleted
                          ? const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            )
                          : null,
                      color: isCompleted ? null : Colors.transparent,
                      border: Border.all(
                        color: _statusColor(task.status) ?? colors.outline,
                        width: 2.5,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                        : task.status == TaskStatus.inProgress
                            ? Padding(
                                padding: const EdgeInsets.all(4),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: _statusColor(task.status),
                                ),
                              )
                            : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isCompleted
                                    ? colors.onSurface.withAlpha(100)
                                    : colors.onSurface,
                                letterSpacing: -0.3,
                              ),
                              child: Text(task.title),
                            ),
                          ),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            color: colors.surface,
                            elevation: 8,
                            shadowColor: colors.shadow,
                            surfaceTintColor: colors.surfaceTint,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: colors.outline),
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditDialog(context, ref);
                              } else if (value == 'delete') {
                                HapticFeedback.mediumImpact();
                                ref.read(taskProvider.notifier).deleteTask(task.id);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit_rounded, size: 20,
                                      color: colors.primary),
                                  title: Text('Editar',
                                      style: GoogleFonts.poppins()),
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete_rounded, size: 20,
                                      color: colors.error),
                                  title: Text('Eliminar',
                                      style: GoogleFonts.poppins(
                                          color: colors.error)),
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            task.description,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: colors.onSurface.withAlpha(150),
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _Tag(
                            icon: _categoryIcon(task.category),
                            label: _categoryLabel(task.category),
                            color: colors.primary,
                          ),
                          const SizedBox(width: 6),
                          _Tag(
                            icon: Icons.circle_rounded,
                            label: task.priority.name.toUpperCase(),
                            color: _priorityColor(task.priority),
                            isDot: true,
                          ),
                          if (task.dueDate != null) ...[
                            const SizedBox(width: 6),
                            _Tag(
                              icon: Icons.calendar_today_rounded,
                              label: '${task.dueDate!.day}/${task.dueDate!.month}',
                              color: colors.onSurface.withAlpha(120),
                              isSubtle: true,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskDetail(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (_statusColor(task.status) ?? colors.outline).withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (_statusColor(task.status) ?? colors.outline).withAlpha(50),
                    ),
                  ),
                  child: Text(
                    task.status.name[0].toUpperCase() + task.status.name.substring(1),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(task.status) ?? colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  _categoryIcon(task.category),
                  _categoryLabel(task.category),
                  colors.primary,
                ),
                _buildInfoChip(
                  Icons.flag_rounded,
                  task.priority.name,
                  _priorityColor(task.priority),
                ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                task.description,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: colors.onSurface.withAlpha(180),
                  height: 1.6,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16,
                    color: colors.onSurface.withAlpha(100)),
                const SizedBox(width: 8),
                Text(
                  'Creada: ${_formatDate(task.createdAt)}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: colors.onSurface.withAlpha(100),
                  ),
                ),
              ],
            ),
            if (task.dueDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.event_rounded, size: 16,
                      color: colors.onSurface.withAlpha(100)),
                  const SizedBox(width: 8),
                  Text(
                    'Vence: ${_formatDate(task.dueDate!)}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: colors.onSurface.withAlpha(100),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label[0].toUpperCase() + label.substring(1),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Editar tarea', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskCategory>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: TaskCategory.values.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name[0].toUpperCase() + c.name.substring(1)),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => category = v!),
                ),
                const SizedBox(height: 12),
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
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: GoogleFonts.poppins()),
            ),
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
              child: Text('Guardar', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDot;
  final bool isSubtle;

  const _Tag({
    required this.icon,
    required this.label,
    required this.color,
    this.isDot = false,
    this.isSubtle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSubtle
            ? color.withAlpha(15)
            : color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDot)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            )
          else
            Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: isDot ? 0.5 : 0,
            ),
          ),
        ],
      ),
    );
  }
}
