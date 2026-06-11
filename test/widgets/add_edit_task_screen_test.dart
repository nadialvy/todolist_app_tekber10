import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todolist_app_tekber10/models/task.dart';
import 'package:todolist_app_tekber10/providers/task_provider.dart';
import 'package:todolist_app_tekber10/screens/add_edit_task_screen.dart';

Widget buildTestApp({Task? task}) {
  return ChangeNotifierProvider(
    create: (_) => TaskProvider(),
    child: MaterialApp(
      home: AddEditTaskScreen(task: task),
    ),
  );
}

Task makeSampleTask() {
  return Task(
    id: 'edit-1',
    title: 'Existing Task',
    description: 'An existing task description',
    deadline: DateTime(2025, 12, 31, 10, 0),
    status: TaskStatus.ongoing,
    priority: TaskPriority.high,
    createdAt: DateTime(2025, 12, 1),
  );
}

void main() {
  group('AddEditTaskScreen - Add mode', () {
    testWidgets('should render Add Task AppBar title', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Add Task'), findsWidgets);
    });

    testWidgets('should render Title field', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('should render Description field', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('should render Deadline section', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Deadline'), findsOneWidget);
    });

    testWidgets('should render Priority dropdown', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Priority'), findsOneWidget);
    });

    testWidgets('should NOT show Status dropdown in add mode', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Status'), findsNothing);
    });

    testWidgets('should render check/save icon button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should show title validation error when saving empty form', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      expect(find.text('Please enter a title'), findsOneWidget);
    });

    testWidgets('should show description validation error when title filled but description empty', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'My Task Title',
      );

      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      expect(find.text('Please enter a description'), findsOneWidget);
    });

    testWidgets('title field accepts text input', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, 'New Task Title');
      await tester.pump();

      expect(find.text('New Task Title'), findsOneWidget);
    });
  });

  group('AddEditTaskScreen - Edit mode', () {
    testWidgets('should render Edit Task AppBar title', (tester) async {
      await tester.pumpWidget(buildTestApp(task: makeSampleTask()));
      await tester.pump();
      expect(find.text('Edit Task'), findsWidgets);
    });

    testWidgets('should pre-fill title from existing task', (tester) async {
      await tester.pumpWidget(buildTestApp(task: makeSampleTask()));
      await tester.pump();
      expect(find.text('Existing Task'), findsOneWidget);
    });

    testWidgets('should pre-fill description from existing task', (tester) async {
      await tester.pumpWidget(buildTestApp(task: makeSampleTask()));
      await tester.pump();
      expect(find.text('An existing task description'), findsOneWidget);
    });

    testWidgets('should show Status dropdown in edit mode', (tester) async {
      await tester.pumpWidget(buildTestApp(task: makeSampleTask()));
      await tester.pump();
      expect(find.text('Status'), findsOneWidget);
    });
  });
}
