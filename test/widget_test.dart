import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_tasks/screens/home_screen.dart';

void main() {
  testWidgets('app renders home screen with all key elements', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );

    expect(find.text('Riverpod Tasks'), findsOneWidget);
    expect(find.text('Nueva tarea'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Pendientes'), findsAtLeast(1));
    expect(find.text('En curso'), findsAtLeast(1));
    expect(find.text('Completadas'), findsAtLeast(1));
    expect(find.text('Todas'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('navigates to add task screen on FAB tap', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );

    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();

    expect(find.text('Guardar tarea'), findsOneWidget);
    expect(find.text('Categoría'), findsOneWidget);
  });

  testWidgets('shows empty state when no tasks', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );

    expect(find.text('No hay tareas'), findsOneWidget);
    expect(find.text('Agrega tu primera tarea'), findsOneWidget);
  });
}
