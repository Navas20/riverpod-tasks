import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/task_provider.dart';

class StatsGrid extends ConsumerWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _StatCard(
            label: 'Total',
            value: taskState.totalTasks,
            icon: Icons.task_alt_rounded,
            gradientColors: [colors.primary, colors.primary.withAlpha(180)],
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Pendientes',
            value: taskState.pendingTasks,
            icon: Icons.pending_actions_rounded,
            gradientColors: const [Color(0xFFF59E0B), Color(0xFFF97316)],
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'En curso',
            value: taskState.inProgressTasks,
            icon: Icons.hourglass_top_rounded,
            gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Completadas',
            value: taskState.completedTasks,
            icon: Icons.check_circle_rounded,
            gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final String label;
  final int value;
  final IconData icon;
  final List<Color> gradientColors;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradientColors,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _displayValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.addListener(() {
      setState(() {
        _displayValue = (_animation.value * widget.value).round();
      });
    });
    if (widget.value > 0) _controller.forward();
  }

  @override
  void didUpdateWidget(_StatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.reset();
      _displayValue = oldWidget.value;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.gradientColors.first.withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(widget.icon, color: Colors.white.withAlpha(220), size: 22),
            const SizedBox(height: 6),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Text(
                  '$_displayValue',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                );
              },
            ),
            Text(
              widget.label,
              style: GoogleFonts.poppins(
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
