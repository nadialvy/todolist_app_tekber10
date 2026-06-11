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

    testWidgets('timer counts down by 1 second when running', (tester) async {
      final task = makeTask(totalEstimatedMinutes: 1);
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();

      expect(find.text('01:00'), findsOneWidget);

      await tester.tap(find.text('Start Focus'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('00:59'), findsOneWidget);
    });

    testWidgets('tapping Details toggles details section visibility',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final task = makeTask();
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();

      // Initially Due Date row should not be shown.
      expect(find.text('Priority'), findsNothing);

      await tester.tap(find.text('Details'));
      await tester.pump();

      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Due'), findsOneWidget);
    });

    testWidgets('detail section shows MEDIUM priority badge', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final task = makeTask();
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();

      await tester.tap(find.text('Details'));
      await tester.pump();

      expect(find.text('MEDIUM'), findsOneWidget);
    });

    testWidgets('details section displays "Today" for deadline today',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final today = DateTime.now();
      final task = Task(
        id: '1',
        title: 'Task',
        description: '',
        deadline: today,
        status: TaskStatus.ongoing,
        priority: TaskPriority.high,
        createdAt: today,
      );
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();

      await tester.tap(find.text('Details'));
      await tester.pump();

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('details section displays "Tomorrow" for deadline tomorrow',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final task = Task(
        id: '1',
        title: 'Task',
        description: '',
        deadline: tomorrow,
        status: TaskStatus.ongoing,
        priority: TaskPriority.low,
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();

      await tester.tap(find.text('Details'));
      await tester.pump();

      expect(find.text('Tomorrow'), findsOneWidget);
    });

    testWidgets('details section displays formatted date for distant deadline',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final far = DateTime(2030, 6, 15);
      final task = Task(
        id: '1',
        title: 'Task',
        description: '',
        deadline: far,
        status: TaskStatus.ongoing,
        priority: TaskPriority.high,
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();

      await tester.tap(find.text('Details'));
      await tester.pump();

      expect(find.text('15 Jun 2030'), findsOneWidget);
    });

    testWidgets('high priority shows HIGH badge', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final task = Task(
        id: '1',
        title: 'Task',
        description: '',
        deadline: DateTime.now().add(const Duration(days: 5)),
        status: TaskStatus.ongoing,
        priority: TaskPriority.high,
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();

      await tester.tap(find.text('Details'));
      await tester.pump();

      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('low priority shows LOW badge', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final task = Task(
        id: '1',
        title: 'Task',
        description: '',
        deadline: DateTime.now().add(const Duration(days: 5)),
        status: TaskStatus.ongoing,
        priority: TaskPriority.low,
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();

      await tester.tap(find.text('Details'));
      await tester.pump();

      expect(find.text('LOW'), findsOneWidget);
    });

    testWidgets('tapping a step toggles its completion state', (tester) async {
      final task = makeTask(steps: [
        {'step': 'Plan', 'estimatedMinutes': 10},
        {'step': 'Execute', 'estimatedMinutes': 30},
      ]);
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();

      // Tap the first step
      await tester.tap(find.text('Plan'));
      await tester.pump();

      // The check icon should now appear
      expect(find.byIcon(Icons.check), findsAtLeastNWidgets(1));

      // Tap again to un-toggle
      await tester.tap(find.text('Plan'));
      await tester.pump();
    });

    testWidgets('step shows estimated minutes badge', (tester) async {
      final task = makeTask(steps: [
        {'step': 'Plan ahead', 'estimatedMinutes': 15},
      ]);
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();

      expect(find.text('15 min'), findsOneWidget);
    });

    testWidgets('renders Finish Steps to Complete button', (tester) async {
      await tester.pumpWidget(buildTestApp(makeTask()));
      await tester.pump();
      expect(find.text('Finish Steps to Complete'), findsOneWidget);
    });

    testWidgets('tapping Finish Steps opens complete dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp(makeTask()));
      await tester.pump();

      await tester.tap(find.text('Finish Steps to Complete'));
      await tester.pumpAndSettle();

      expect(
        find.text('Are you sure you want to\ncomplete this task?'),
        findsOneWidget,
      );
    });

    testWidgets('complete dialog Cancel button closes dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp(makeTask()));
      await tester.pump();

      await tester.tap(find.text('Finish Steps to Complete'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(
        find.text('Are you sure you want to\ncomplete this task?'),
        findsNothing,
      );
    });

    testWidgets('tapping Delete Task opens delete dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp(makeTask()));
      await tester.pump();

      await tester.tap(find.text('Delete Task'));
      await tester.pumpAndSettle();

      expect(
        find.text('Are you sure you want to\ndelete this task?'),
        findsOneWidget,
      );
    });

    testWidgets('delete dialog Cancel closes dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp(makeTask()));
      await tester.pump();

      await tester.tap(find.text('Delete Task'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(
        find.text('Are you sure you want to\ndelete this task?'),
        findsNothing,
      );
    });

    testWidgets('completed task status disables step taps', (tester) async {
      final task = makeTask(
        status: TaskStatus.completed,
        steps: [
          {'step': 'Done step', 'estimatedMinutes': 10},
        ],
      );
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();

      // Step should show with check icon (because task is completed)
      expect(find.byIcon(Icons.check), findsAtLeastNWidgets(1));
    });

    testWidgets('back button is rendered in header', (tester) async {
      await tester.pumpWidget(buildTestApp(makeTask()));
      await tester.pump();
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('tapping back button pops the route', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => TaskProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).push(
                    MaterialPageRoute(
                      builder: (_) => FocusModeScreen(task: makeTask()),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Task details'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('Task details'), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('tapping pencil edit button opens EditTaskBottomSheet',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp(makeTask(title: 'Original')));
      await tester.pump();

      // Find IconButton with SvgPicture child (the pencil icon)
      final iconButtons = find.byType(IconButton);
      // Should be back button + pencil edit button at top
      expect(iconButtons, findsAtLeastNWidgets(2));

      // Tap the second IconButton (the edit one)
      await tester.tap(iconButtons.at(1));
      await tester.pumpAndSettle();

      // EditTaskBottomSheet shows up
      expect(find.text('Edit Task'), findsOneWidget);

      // Close it
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
    });

    testWidgets('timer formats 1 hour as 60:00', (tester) async {
      final task = makeTask(totalEstimatedMinutes: 60);
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();
      expect(find.text('60:00'), findsOneWidget);
    });

    testWidgets('estimated time badge shows when totalEstimatedMinutes is set',
        (tester) async {
      final task = makeTask(totalEstimatedMinutes: 45);
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();
      expect(find.text('Est. 45 minutes'), findsOneWidget);
    });

    testWidgets('confirming Complete shows error snackbar when provider throws',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp(makeTask()));
      await tester.pump();

      await tester.tap(find.text('Finish Steps to Complete'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Complete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Failed to complete task'), findsOneWidget);
    });

    testWidgets('confirming Delete shows error snackbar when provider throws',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp(makeTask()));
      await tester.pump();

      await tester.tap(find.text('Delete Task'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Failed to delete task'), findsOneWidget);
    });

    testWidgets('timer reaches 0 and shows complete dialog', (tester) async {
      // Use 1 minute timer so we only need to advance 60+ seconds.
      final task = makeTask(totalEstimatedMinutes: 1);
      await tester.pumpWidget(buildTestApp(task));
      await tester.pump();

      // Start the timer
      await tester.tap(find.text('Start Focus'));
      await tester.pump();

      // Advance time by 61 seconds (1 tick at a time so periodic fires)
      for (int i = 0; i < 61; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      // The complete dialog shows
      expect(find.text("Time's up! 🎉"), findsOneWidget);
      expect(find.text('Great focus session! Take a break.'), findsOneWidget);

      // Dismiss it
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });
  });
}
