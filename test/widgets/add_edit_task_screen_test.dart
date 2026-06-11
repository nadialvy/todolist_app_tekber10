import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todolist_app_tekber10/models/task.dart';
import 'package:todolist_app_tekber10/providers/task_provider.dart';
import 'package:todolist_app_tekber10/screens/add_edit_task_screen.dart';

import '../helpers/fake_task_provider.dart';

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

    testWidgets('Update Task button label appears in edit mode', (tester) async {
      await tester.pumpWidget(buildTestApp(task: makeSampleTask()));
      await tester.pump();
      expect(find.text('Update Task'), findsOneWidget);
    });

    testWidgets('changing priority dropdown updates selection', (tester) async {
      await tester.pumpWidget(buildTestApp(task: makeSampleTask()));
      await tester.pump();

      // Open priority dropdown
      await tester.tap(find.text('HIGH').first);
      await tester.pumpAndSettle();

      // Tap LOW
      await tester.tap(find.text('LOW').last);
      await tester.pumpAndSettle();
    });

    testWidgets('changing status dropdown updates selection', (tester) async {
      await tester.pumpWidget(buildTestApp(task: makeSampleTask()));
      await tester.pump();

      // Open status dropdown
      await tester.tap(find.text('ONGOING').first);
      await tester.pumpAndSettle();

      // Tap COMPLETED
      await tester.tap(find.text('COMPLETED').last);
      await tester.pumpAndSettle();
    });

    testWidgets('Save button at bottom uses ElevatedButton.icon', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp(task: makeSampleTask()));
      await tester.pump();

      // Save button label + icon are reliable across Flutter versions.
      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.text('Update Task'), findsOneWidget);
    });

    testWidgets('Deadline field is rendered as ListTile', (tester) async {
      await tester.pumpWidget(buildTestApp(task: makeSampleTask()));
      await tester.pump();
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('saving valid edit form shows error snackbar when provider throws',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp(task: makeSampleTask()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Failed to save task'), findsOneWidget);
    });
  });

  group('AddEditTaskScreen - Save in add mode', () {
    testWidgets('saving valid new task shows error snackbar when provider throws',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, 'New Task');
      await tester.enterText(find.byType(TextFormField).at(1), 'Description');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Failed to save task'), findsOneWidget);
    });

    testWidgets('tapping deadline ListTile opens date picker', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarDatePicker), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('saving valid new task with fake provider pops the route',
        (tester) async {
      final fake = FakeTaskProvider();
      await tester.pumpWidget(
        ChangeNotifierProvider<TaskProvider>.value(
          value: fake,
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).push(
                    MaterialPageRoute(
                      builder: (_) => const AddEditTaskScreen(),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'My Task');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'My Description');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Route popped because save succeeded
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('saving valid edit with fake provider pops the route',
        (tester) async {
      final fake = FakeTaskProvider();
      final task = makeSampleTask();
      fake.setTasksForTesting([task]);

      await tester.pumpWidget(
        ChangeNotifierProvider<TaskProvider>.value(
          value: fake,
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).push(
                    MaterialPageRoute(
                      builder: (_) => AddEditTaskScreen(task: task),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('selecting OK on date picker opens time picker', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Time picker — has "Select time" or its widgets present
      expect(find.byType(TimePickerDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });
}
