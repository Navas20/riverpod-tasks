import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_tasks/models/task.dart';
import 'package:riverpod_tasks/providers/filter_provider.dart';
import 'package:riverpod_tasks/providers/task_provider.dart';
import 'package:riverpod_tasks/providers/task_list_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('filteredTasksProvider', () {
    setUp(() {
      container.read(taskProvider.notifier).addTask(title: 'Task 1', category: TaskCategory.work);
      container.read(taskProvider.notifier).addTask(title: 'Task 2', category: TaskCategory.personal);
      container.read(taskProvider.notifier).addTask(title: 'Task 3', category: TaskCategory.work);

      container.read(taskProvider.notifier).toggleStatus(
        container.read(taskProvider).tasks[2].id,
      );
      container.read(taskProvider.notifier).toggleStatus(
        container.read(taskProvider).tasks[2].id,
      );
    });

    test('shows all tasks by default', () {
      final tasks = container.read(filteredTasksProvider);
      expect(tasks.length, 3);
    });

    test('filters by pending', () {
      container.read(filterTypeProvider.notifier).state = FilterType.pending;
      final tasks = container.read(filteredTasksProvider);
      expect(tasks.length, 2);
    });

    test('filters by completed', () {
      container.read(filterTypeProvider.notifier).state = FilterType.completed;
      final tasks = container.read(filteredTasksProvider);
      expect(tasks.length, 1);
    });

    test('filters by category', () {
      container.read(categoryFilterProvider.notifier).state = TaskCategory.work;
      final tasks = container.read(filteredTasksProvider);
      expect(tasks.length, 2);
    });

    test('filters by search query', () {
      container.read(searchQueryProvider.notifier).state = 'Task 1';
      final tasks = container.read(filteredTasksProvider);
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Task 1');
    });

    test('combines category and status filters', () {
      container.read(categoryFilterProvider.notifier).state = TaskCategory.work;
      container.read(filterTypeProvider.notifier).state = FilterType.pending;

      final tasks = container.read(filteredTasksProvider);
      expect(tasks.length, 1);
    });

    test('sorts by creation date descending', () {
      final oldTask = Task(
        id: 'old', title: 'Oldest', createdAt: DateTime(2024, 1, 1),
      );
      final newTask = Task(
        id: 'new', title: 'Newest', createdAt: DateTime(2025, 1, 1),
      );

      final notifier = container.read(taskProvider.notifier);
      notifier.state = notifier.state.copyWith(
        tasks: [oldTask, newTask],
      );

      container.read(categoryFilterProvider.notifier).state = null;
      container.read(filterTypeProvider.notifier).state = FilterType.all;

      final tasks = container.read(filteredTasksProvider);
      expect(tasks.first.title, 'Newest');
      expect(tasks.last.title, 'Oldest');
    });

    test('returns empty when no match', () {
      container.read(filterTypeProvider.notifier).state = FilterType.inProgress;
      final tasks = container.read(filteredTasksProvider);
      expect(tasks, isEmpty);
    });

    test('resets category filter to null', () {
      container.read(categoryFilterProvider.notifier).state = TaskCategory.work;
      expect(container.read(categoryFilterProvider), TaskCategory.work);

      container.read(categoryFilterProvider.notifier).state = null;
      expect(container.read(categoryFilterProvider), isNull);

      final tasks = container.read(filteredTasksProvider);
      expect(tasks.length, 3);
    });
  });

  group('taskStatsProvider', () {
    test('reflects current task state', () {
      final stats = container.read(taskStatsProvider);
      expect(stats.totalTasks, 0);

      container.read(taskProvider.notifier).addTask(title: 'Test');
      final updatedStats = container.read(taskStatsProvider);
      expect(updatedStats.totalTasks, 1);
    });
  });
}
