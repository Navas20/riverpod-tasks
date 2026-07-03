import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../providers/filter_provider.dart';
import '../providers/task_list_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/stats_grid.dart';
import 'add_task_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = ref.watch(filteredTasksProvider);
    final currentFilter = ref.watch(filterTypeProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Limpiar completadas',
            onPressed: () {
              HapticFeedback.lightImpact();
              final taskState = ref.read(taskProvider);
              for (final task in taskState.tasks) {
                if (task.status == TaskStatus.completed) {
                  ref.read(taskProvider.notifier).deleteTask(task.id);
                }
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Tareas completadas eliminadas'),
                  backgroundColor: colors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar tareas...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
                setState(() {});
              },
            ),
          ),
          const StatsGrid(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: FilterType.values.map((filter) {
                  final isSelected = currentFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filterLabel(filter)),
                      selected: isSelected,
                      selectedColor: colors.primary,
                      labelStyle: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : colors.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 13,
                      ),
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        ref.read(filterTypeProvider.notifier).state = filter;
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                );
              },
              child: filteredTasks.isEmpty
                  ? _buildEmptyState(theme, colors, currentFilter)
                  : _buildTaskList(filteredTasks, colors),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const AddTaskScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva tarea'),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colors, FilterType filter) {
    return Center(
      key: const ValueKey('empty'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withAlpha(15),
                    colors.secondary.withAlpha(10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_rounded,
                size: 56,
                color: colors.primary.withAlpha(100),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay tareas',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.onSurface.withAlpha(150),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filter != FilterType.all
                  ? 'Prueba con otro filtro'
                  : 'Agrega tu primera tarea',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: colors.onSurface.withAlpha(100),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, ColorScheme colors) {
    return ListView.builder(
      key: const ValueKey('list'),
      controller: _scrollCtrl,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 4, bottom: 88),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _AnimatedTaskItem(
          index: index,
          task: tasks[index],
          child: Dismissible(
            key: ValueKey(tasks[index].id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: colors.error.withAlpha(40),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.delete_rounded, color: colors.error, size: 28),
            ),
            confirmDismiss: (direction) async {
              HapticFeedback.mediumImpact();
              return true;
            },
            onDismissed: (_) {
              ref.read(taskProvider.notifier).deleteTask(tasks[index].id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Tarea eliminada'),
                  action: SnackBarAction(
                    label: 'Deshacer',
                    textColor: colors.tertiary,
                    onPressed: () {},
                  ),
                ),
              );
            },
            child: TaskCard(task: tasks[index]),
          ),
        );
      },
    );
  }

  String _filterLabel(FilterType filter) {
    return switch (filter) {
      FilterType.all => 'Todas',
      FilterType.pending => 'Pendientes',
      FilterType.inProgress => 'En curso',
      FilterType.completed => 'Completadas',
    };
  }
}

class _AnimatedTaskItem extends StatefulWidget {
  final int index;
  final Task task;
  final Widget child;

  const _AnimatedTaskItem({
    required this.index,
    required this.task,
    required this.child,
  });

  @override
  State<_AnimatedTaskItem> createState() => _AnimatedTaskItemState();
}

class _AnimatedTaskItemState extends State<_AnimatedTaskItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    final staggerDelay = Duration(milliseconds: (widget.index * 60).clamp(0, 500));
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(staggerDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(opacity: _fade, child: widget.child),
    );
  }
}
