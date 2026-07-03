import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';

final _uuid = _UuidGenerator();

class _UuidGenerator {
  int _counter = 0;
  String v4() => 'task_${DateTime.now().millisecondsSinceEpoch}_${_counter++}';
}

class TaskState {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;

  const TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
  });

  TaskState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get totalTasks => tasks.length;
  int get completedTasks => tasks.where((t) => t.status == TaskStatus.completed).length;
  int get pendingTasks => tasks.where((t) => t.status == TaskStatus.pending).length;
  int get inProgressTasks => tasks.where((t) => t.status == TaskStatus.inProgress).length;
}

class TaskNotifier extends StateNotifier<TaskState> {
  TaskNotifier() : super(const TaskState());

  void addTask({
    required String title,
    String description = '',
    TaskCategory category = TaskCategory.other,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      priority: priority,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );
    state = state.copyWith(
      tasks: [...state.tasks, task],
    );
  }

  void updateTask(Task updatedTask) {
    state = state.copyWith(
      tasks: state.tasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList(),
    );
  }

  void deleteTask(String id) {
    state = state.copyWith(
      tasks: state.tasks.where((t) => t.id != id).toList(),
    );
  }

  void toggleStatus(String id) {
    state = state.copyWith(
      tasks: state.tasks.map((t) {
        if (t.id != id) return t;
        final nextStatus = switch (t.status) {
          TaskStatus.pending => TaskStatus.inProgress,
          TaskStatus.inProgress => TaskStatus.completed,
          TaskStatus.completed => TaskStatus.pending,
        };
        return t.copyWith(status: nextStatus);
      }).toList(),
    );
  }

  List<Task> tasksByCategory(TaskCategory category) {
    return state.tasks.where((t) => t.category == category).toList();
  }

  List<Task> tasksByPriority(TaskPriority priority) {
    return state.tasks.where((t) => t.priority == priority).toList();
  }

  List<Task> searchTasks(String query) {
    if (query.isEmpty) return state.tasks;
    final q = query.toLowerCase();
    return state.tasks.where((t) =>
      t.title.toLowerCase().contains(q) ||
      t.description.toLowerCase().contains(q)
    ).toList();
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier();
});
