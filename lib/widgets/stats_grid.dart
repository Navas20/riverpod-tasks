import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';

class StatsGrid extends ConsumerWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _StatCard(
            label: 'Total',
            value: '${taskState.totalTasks}',
            icon: Icons.task_alt,
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'Pendientes',
            value: '${taskState.pendingTasks}',
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'En curso',
            value: '${taskState.inProgressTasks}',
            icon: Icons.hourglass_top,
            color: Colors.purple,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'Completadas',
            value: '${taskState.completedTasks}',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
