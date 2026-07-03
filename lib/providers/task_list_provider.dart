import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import 'task_provider.dart';
import 'filter_provider.dart';

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final taskState = ref.watch(taskProvider);
  final filterType = ref.watch(filterTypeProvider);
  final categoryFilter = ref.watch(categoryFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  var tasks = taskState.tasks.toList();

  if (categoryFilter != null) {
    tasks = tasks.where((t) => t.category == categoryFilter).toList();
  }

  tasks = switch (filterType) {
    FilterType.all => tasks,
    FilterType.pending => tasks.where((t) => t.status == TaskStatus.pending).toList(),
    FilterType.inProgress => tasks.where((t) => t.status == TaskStatus.inProgress).toList(),
    FilterType.completed => tasks.where((t) => t.status == TaskStatus.completed).toList(),
  };

  if (searchQuery.isNotEmpty) {
    final q = searchQuery.toLowerCase();
    tasks = tasks.where((t) =>
      t.title.toLowerCase().contains(q) ||
      t.description.toLowerCase().contains(q)
    ).toList();
  }

  tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return tasks;
});

final taskStatsProvider = Provider<TaskState>((ref) {
  return ref.watch(taskProvider);
});
