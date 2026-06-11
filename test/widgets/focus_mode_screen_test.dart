import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist_app_tekber10/models/task.dart';
import 'package:todolist_app_tekber10/providers/task_provider.dart';
import 'package:todolist_app_tekber10/providers/theme_provider.dart';
import 'package:todolist_app_tekber10/screens/focus_mode_screen.dart';

Task makeTask({
  String id = '1',
  String title = 'Test Task',
  TaskStatus status = TaskStatus.ongoing,
  List<Map<String, dynamic>>? steps,
  int? totalEstimatedMinutes,
}) {
  return Task(
    id: id,
    title: title,
    description: 'Test description',
    deadline: DateTime.now().add(const Duration(days: 1)),
    status: status,
    priority: TaskPriority.medium,
    createdAt: DateTime.now(),
    steps: steps,
    totalEstimatedMinutes: totalEstimatedMinutes,
  );
}

Widget buildTestApp(Task task, {TaskProvider? taskProvider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: taskProvider ?? TaskProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: Builder(
      builder: (ctx) {
        final tp = Provider.of<ThemeProvider>(ctx);
        return MaterialApp(
          theme: tp.lightTheme,
          home: FocusModeScreen(task: task),
        );
      },
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FocusModeScreen', () {
    testWidgets('should render Task details header', (tester) async {
      await tester.pumpWidget(buildTestApp(makeTask()));
      await tester.pump();
      expect(find.text('Task details'), findsOneWidget);
    });

    testWidgets('should render task title', (tester) async {
      await tester.pumpWidget(buildTestApp(makeTask(title: 'Write unit tests')));
      await tester.pump();
      expect(find.text('Write unit tests'), findsOneWidget);
    });

    testWidgets('should render Start Focus button initially', (tester) async {
      await tester.pumpWidget(buildTestApp(makeTask()));
      await tester.pump();
      expect(find.text('Start Focus'), findsOneWidget);
    });

    testWidgets('should NOT show Pause Focus before timer starts', (tester) async {
      await tester.pumpWidget(buildTestApp(makeTask()));
      await tester.pump();
      expect(find.text('Pause Focus'), findsNothing);
    });

    testWidgets('tapping Start Focus changes to Pause Focus', (tester) async {
      await tester.pumpWidget(buildTestApp(makeTask()));
      await tester.pump();

      await tester.tap(find.text('Start Focus'));
      await tester.pump();

      expect(find.text('Pause Focus'), findsOneWidget);
      expect(find.text('Start Focus'), findsNothing);
    });

    testWidgets('tapping Pause Focus changes back to Start Focus', (tester) async {
      await tester.pumpWidget(buildTestApp(makeTask()));
      await tester.pump();

      await tester.tap(find.text('Start Focus'));
      await tester.pump();
      await tester.tap(find.text('Pause Focus'));
      await tester.pump();

      expect(find.text('Start Focus'), findsOneWidget);
    });

    testWidgets('should show No specific steps for task without steps', (tester) async {
      await tester.pumpWidget(buildTestApp(makeTask(steps: null)));
      await tester.pump();
      expect(find.textContaining('No specific steps'), findsOneWidget);
    });

    testWidgets('should render step text when steps are present', (tester) async {
      final task = makeTask(steps: [
        {'step': 'Plan the work', 'estimatedMinutes': 10},
        {'step': 'Execute the plan', 'estimatedMinutes': 30},
      ]);
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Plan the work'), 100.0);
      expect(find.text('Plan the work'), findsOneWidget);
    });

    testWidgets('should show estimated time badge for task with totalEstimatedMinutes', (tester) async {
      final task = makeTask(totalEstimatedMinutes: 45);
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();
      expect(find.textContaining('45'), findsWidgets);
    });

    testWidgets('should render Delete Task button', (tester) async {
      await tester.pumpWidget(buildTestApp(makeTask()));
      await tester.pump();
      expect(find.text('Delete Task'), findsOneWidget);
    });

    testWidgets('should render Details expandable section', (tester) async {
      await tester.pumpWidget(buildTestApp(makeTask()));
      await tester.pump();
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('timer displays in MM:SS format', (tester) async {
      final task = makeTask(totalEstimatedMinutes: 20);
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();
      // 20 min * 60 sec = 1200 sec → "20:00"
      expect(find.text('20:00'), findsOneWidget);
    });

    testWidgets('timer defaults to 20:00 when no estimated time', (tester) async {
      final task = makeTask(totalEstimatedMinutes: null);
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();
      expect(find.text('20:00'), findsOneWidget);
    });
  });
}
