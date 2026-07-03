import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';

class StatsGrid extends ConsumerWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _StatCard(
            label: 'Total',
            value: '${taskState.totalTasks}',
            icon: Icons.task_alt_rounded,
            color: theme.colorScheme.primary,
            gradientColors: const [Color(0xFF4F46E5), Color(0xFF6366F1)],
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Pendientes',
            value: '${taskState.pendingTasks}',
            icon: Icons.pending_actions_rounded,
            color: const Color(0xFFF59E0B),
            gradientColors: const [Color(0xFFF59E0B), Color(0xFFF97316)],
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'En curso',
            value: '${taskState.inProgressTasks}',
            icon: Icons.hourglass_top_rounded,
            color: const Color(0xFF8B5CF6),
            gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Completadas',
            value: '${taskState.completedTasks}',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF10B981),
            gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
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
  final List<Color> gradientColors;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white.withAlpha(220), size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
