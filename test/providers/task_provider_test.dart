import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_tasks/models/task.dart';
import 'package:riverpod_tasks/providers/task_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('TaskNotifier', () {
    test('initial state is empty', () {
      final state = container.read(taskProvider);
      expect(state.tasks, isEmpty);
      expect(state.totalTasks, 0);
    });

    test('addTask creates a task correctly', () {
      container.read(taskProvider.notifier).addTask(
        title: 'Test task',
        description: 'Test description',
        category: TaskCategory.work,
        priority: TaskPriority.high,
      );

      final state = container.read(taskProvider);
      expect(state.totalTasks, 1);
      expect(state.tasks.first.title, 'Test task');
      expect(state.tasks.first.description, 'Test description');
      expect(state.tasks.first.category, TaskCategory.work);
      expect(state.tasks.first.priority, TaskPriority.high);
      expect(state.tasks.first.status, TaskStatus.pending);
    });

    test('addTask defaults to sensible values', () {
      container.read(taskProvider.notifier).addTask(title: 'Minimal task');

      final task = container.read(taskProvider).tasks.first;
      expect(task.title, 'Minimal task');
      expect(task.description, '');
      expect(task.category, TaskCategory.other);
      expect(task.priority, TaskPriority.medium);
    });

    test('addTask generates unique IDs', () {
      container.read(taskProvider.notifier).addTask(title: 'Task 1');
      container.read(taskProvider.notifier).addTask(title: 'Task 2');

      final tasks = container.read(taskProvider).tasks;
      expect(tasks[0].id, isNot(tasks[1].id));
    });

    test('updateTask modifies existing task', () {
      container.read(taskProvider.notifier).addTask(title: 'Original');
      final original = container.read(taskProvider).tasks.first;

      container.read(taskProvider.notifier).updateTask(
        original.copyWith(title: 'Updated', priority: TaskPriority.high),
      );

      final updated = container.read(taskProvider).tasks.first;
      expect(updated.title, 'Updated');
      expect(updated.priority, TaskPriority.high);
      expect(updated.id, original.id);
    });

    test('deleteTask removes task by id', () {
      container.read(taskProvider.notifier).addTask(title: 'To delete');
      container.read(taskProvider.notifier).addTask(title: 'Keep');
      final idToDelete = container.read(taskProvider).tasks.first.id;

      container.read(taskProvider.notifier).deleteTask(idToDelete);

      expect(container.read(taskProvider).totalTasks, 1);
      expect(container.read(taskProvider).tasks.first.title, 'Keep');
    });

    test('toggleStatus cycles through pending -> inProgress -> completed -> pending', () {
      container.read(taskProvider.notifier).addTask(title: 'Cycle');
      final task = container.read(taskProvider).tasks.first;

      expect(task.status, TaskStatus.pending);

      container.read(taskProvider.notifier).toggleStatus(task.id);
      expect(container.read(taskProvider).tasks.first.status, TaskStatus.inProgress);

      container.read(taskProvider.notifier).toggleStatus(task.id);
      expect(container.read(taskProvider).tasks.first.status, TaskStatus.completed);

      container.read(taskProvider.notifier).toggleStatus(task.id);
      expect(container.read(taskProvider).tasks.first.status, TaskStatus.pending);
    });

    test('computed counts are correct', () {
      container.read(taskProvider.notifier).addTask(title: 'Task 1');
      container.read(taskProvider.notifier).addTask(title: 'Task 2');
      container.read(taskProvider.notifier).addTask(title: 'Task 3');

      var state = container.read(taskProvider);
      expect(state.totalTasks, 3);
      expect(state.pendingTasks, 3);
      expect(state.completedTasks, 0);

      container.read(taskProvider.notifier).toggleStatus(
        container.read(taskProvider).tasks[0].id,
      );
      container.read(taskProvider.notifier).toggleStatus(
        container.read(taskProvider).tasks[0].id,
      );

      state = container.read(taskProvider);
      expect(state.pendingTasks, 2);
      expect(state.completedTasks, 1);
      expect(state.inProgressTasks, 0);
    });

    test('tasksByCategory filters correctly', () {
      container.read(taskProvider.notifier).addTask(title: 'Work 1', category: TaskCategory.work);
      container.read(taskProvider.notifier).addTask(title: 'Personal 1', category: TaskCategory.personal);
      container.read(taskProvider.notifier).addTask(title: 'Work 2', category: TaskCategory.work);

      final workTasks = container.read(taskProvider.notifier).tasksByCategory(TaskCategory.work);
      expect(workTasks.length, 2);

      final personalTasks = container.read(taskProvider.notifier).tasksByCategory(TaskCategory.personal);
      expect(personalTasks.length, 1);
    });

    test('tasksByPriority filters correctly', () {
      container.read(taskProvider.notifier).addTask(title: 'High', priority: TaskPriority.high);
      container.read(taskProvider.notifier).addTask(title: 'Low', priority: TaskPriority.low);
      container.read(taskProvider.notifier).addTask(title: 'Medium', priority: TaskPriority.medium);

      final highTasks = container.read(taskProvider.notifier).tasksByPriority(TaskPriority.high);
      expect(highTasks.length, 1);
      expect(highTasks.first.title, 'High');
    });

    test('searchTasks finds by title', () {
      container.read(taskProvider.notifier).addTask(title: 'Comprar pan');
      container.read(taskProvider.notifier).addTask(title: 'Estudiar Flutter');
      container.read(taskProvider.notifier).addTask(title: 'Ir al gym');

      final results = container.read(taskProvider.notifier).searchTasks('flutter');
      expect(results.length, 1);
      expect(results.first.title, 'Estudiar Flutter');
    });

    test('searchTasks finds by description', () {
      container.read(taskProvider.notifier).addTask(
        title: 'Tarea',
        description: 'Recordatorio importante',
      );

      final results = container.read(taskProvider.notifier).searchTasks('importante');
      expect(results.length, 1);
    });

    test('searchTasks returns all when query is empty', () {
      container.read(taskProvider.notifier).addTask(title: 'Task 1');
      container.read(taskProvider.notifier).addTask(title: 'Task 2');

      final results = container.read(taskProvider.notifier).searchTasks('');
      expect(results.length, 2);
    });
  });
}
