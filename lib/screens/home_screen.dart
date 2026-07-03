import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = ref.watch(filteredTasksProvider);
    final currentFilter = ref.watch(filterTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Tasks'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Limpiar completadas',
            onPressed: () {
              final taskState = ref.read(taskProvider);
              for (final task in taskState.tasks) {
                if (task.status == TaskStatus.completed) {
                  ref.read(taskProvider.notifier).deleteTask(task.id);
                }
              }
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
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
                setState(() {});
              },
            ),
          ),
          const StatsGrid(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: FilterType.values.map((filter) {
                  final isSelected = currentFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_filterLabel(filter)),
                      selected: isSelected,
                      onSelected: (_) {
                        ref.read(filterTypeProvider.notifier).state = filter;
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay tareas',
                          style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                        ),
                        Text(
                          currentFilter != FilterType.all
                              ? 'Prueba con otro filtro'
                              : 'Agrega tu primera tarea',
                          style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      return TaskCard(task: filteredTasks[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTaskScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
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
