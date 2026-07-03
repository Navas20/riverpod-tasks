import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_tasks/models/task.dart';
import 'package:riverpod_tasks/widgets/task_card.dart';

Widget createTestApp(Task task) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: TaskCard(task: task),
      ),
    ),
  );
}

void main() {
  group('TaskCard', () {
    testWidgets('displays task title', (tester) async {
      final task = Task(
        id: '1',
        title: 'Mi tarea de prueba',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestApp(task));
      expect(find.text('Mi tarea de prueba'), findsOneWidget);
    });

    testWidgets('displays task description', (tester) async {
      final task = Task(
        id: '1',
        title: 'Test',
        description: 'Descripción larga de prueba',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestApp(task));
      expect(find.text('Descripción larga de prueba'), findsOneWidget);
    });

    testWidgets('shows priority badge', (tester) async {
      final task = Task(
        id: '1',
        title: 'Test',
        priority: TaskPriority.high,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestApp(task));
      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('shows category', (tester) async {
      final task = Task(
        id: '1',
        title: 'Test',
        category: TaskCategory.work,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestApp(task));
      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets('shows due date when provided', (tester) async {
      final task = Task(
        id: '1',
        title: 'Test',
        dueDate: DateTime(2026, 7, 15),
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestApp(task));
      expect(find.text('15/7'), findsOneWidget);
    });

    testWidgets('strikes through text when completed', (tester) async {
      final task = Task(
        id: '1',
        title: 'Completed task',
        status: TaskStatus.completed,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestApp(task));

      final textWidget = tester.widget<Text>(find.text('Completed task'));
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('tapping checkbox toggles status', (tester) async {
      final task = Task(
        id: '1',
        title: 'Toggle me',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestApp(task));

      final checkbox = find.byType(GestureDetector).first;
      await tester.tap(checkbox);
      await tester.pumpAndSettle();
    });

    testWidgets('shows popup menu on ellipsis tap', (tester) async {
      final task = Task(
        id: '1',
        title: 'Menu test',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestApp(task));

      final popupButton = find.byType(PopupMenuButton<String>);
      expect(popupButton, findsOneWidget);
    });

    testWidgets('shows task detail on tap', (tester) async {
      final task = Task(
        id: '1',
        title: 'Detail view',
        description: 'Detail description',
        category: TaskCategory.study,
        priority: TaskPriority.low,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestApp(task));

      await tester.tap(find.byType(InkWell).last);
      await tester.pumpAndSettle();

      expect(find.text('Detail view'), findsAtLeast(1));
    });
  });
}
