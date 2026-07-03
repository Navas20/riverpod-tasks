import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_tasks/providers/task_provider.dart';
import 'package:riverpod_tasks/widgets/stats_grid.dart';

void main() {
  testWidgets('shows all zero stats initially', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: Scaffold(body: StatsGrid()))),
    );

    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Pendientes'), findsOneWidget);
    expect(find.text('En curso'), findsOneWidget);
    expect(find.text('Completadas'), findsOneWidget);
  });

  testWidgets('updates stats via ProviderContainer', (tester) async {
    final container = ProviderContainer();
    container.read(taskProvider.notifier).addTask(title: 'Task 1');
    container.read(taskProvider.notifier).addTask(title: 'Task 2');
    container.read(taskProvider.notifier).addTask(title: 'Task 3');

    addTearDown(() => container.dispose());

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: StatsGrid())),
      ),
    );

    await tester.pump();

    expect(find.text('3'), findsAtLeast(1));
    expect(find.text('0'), findsAtLeast(1));
  });

  testWidgets('updates when tasks change status', (tester) async {
    final container = ProviderContainer();
    container.read(taskProvider.notifier).addTask(title: 'Task 1');
    final id = container.read(taskProvider).tasks.first.id;
    container.read(taskProvider.notifier).toggleStatus(id);
    container.read(taskProvider.notifier).toggleStatus(id);

    addTearDown(() => container.dispose());

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: StatsGrid())),
      ),
    );

    await tester.pump();

    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('0'), findsNWidgets(2));
  });
}
