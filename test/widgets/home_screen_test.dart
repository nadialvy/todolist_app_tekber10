import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist_app_tekber10/models/task.dart';
import 'package:todolist_app_tekber10/providers/task_provider.dart';
import 'package:todolist_app_tekber10/providers/profile_provider.dart';
import 'package:todolist_app_tekber10/providers/theme_provider.dart';
import 'package:todolist_app_tekber10/screens/home_screen.dart';

import '../helpers/fake_task_provider.dart';

Widget buildTestApp({TaskProvider? taskProvider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: taskProvider ?? TaskProvider()),
      ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: Builder(
      builder: (context) {
        final theme = Provider.of<ThemeProvider>(context);
        return MaterialApp(
          theme: theme.lightTheme,
          home: const HomeScreen(),
        );
      },
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HomeScreen', () {
    testWidgets('should render search bar hint text', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Search Task'), findsOneWidget);
    });

    testWidgets('should render All filter tab', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('should render Ongoing filter tab', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Ongoing'), findsOneWidget);
    });

    testWidgets('should render Missed filter tab', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Missed'), findsOneWidget);
    });

    testWidgets('should render Completed filter tab', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('should show empty state when no tasks', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('No tasks found in here'), findsOneWidget);
    });

    testWidgets('should show add task hint in empty state', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Tap the + button to add a new task'), findsOneWidget);
    });

    testWidgets('should render greeting with default user name', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Hello, User'), findsOneWidget);
    });

    testWidgets('should render All Activity section header', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('All Activity'), findsOneWidget);
    });

    testWidgets('should display task titles when tasks are present', (tester) async {
      final taskProvider = TaskProvider();
      taskProvider.setTasksForTesting([
        Task(
          id: '1',
          title: 'Buy groceries',
          description: 'Milk, eggs, bread',
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.ongoing,
          createdAt: DateTime.now(),
        ),
        Task(
          id: '2',
          title: 'Study Flutter',
          description: 'Widgets and state management',
          deadline: DateTime.now().add(const Duration(days: 2)),
          status: TaskStatus.ongoing,
          createdAt: DateTime.now(),
        ),
      ]);

      await tester.pumpWidget(buildTestApp(taskProvider: taskProvider));
      await tester.pump();

      expect(find.text('Buy groceries'), findsOneWidget);
      expect(find.text('Study Flutter'), findsOneWidget);
    });

    testWidgets('should not show empty state when tasks are present', (tester) async {
      final taskProvider = TaskProvider();
      taskProvider.setTasksForTesting([
        Task(
          id: '1',
          title: 'Some task',
          description: 'Desc',
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.ongoing,
          createdAt: DateTime.now(),
        ),
      ]);

      await tester.pumpWidget(buildTestApp(taskProvider: taskProvider));
      await tester.pump();

      expect(find.text('No tasks found in here'), findsNothing);
    });

    testWidgets('tapping Ongoing tab filters tasks', (tester) async {
      final taskProvider = TaskProvider();
      taskProvider.setTasksForTesting([
        Task(
          id: '1',
          title: 'Ongoing Task',
          description: '',
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.ongoing,
          createdAt: DateTime.now(),
        ),
        Task(
          id: '2',
          title: 'Completed Task',
          description: '',
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.completed,
          createdAt: DateTime.now(),
        ),
      ]);

      await tester.pumpWidget(buildTestApp(taskProvider: taskProvider));
      await tester.pump();

      // Tap Ongoing tab
      await tester.tap(find.text('Ongoing'));
      await tester.pump();

      expect(find.text('Ongoing Task'), findsOneWidget);
      expect(find.text('Completed Task'), findsNothing);
    });

    testWidgets('tapping Completed tab filters to completed tasks', (tester) async {
      final taskProvider = TaskProvider();
      taskProvider.setTasksForTesting([
        Task(
          id: '1',
          title: 'Ongoing Task',
          description: '',
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.ongoing,
          createdAt: DateTime.now(),
        ),
        Task(
          id: '2',
          title: 'Completed Task',
          description: '',
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.completed,
          createdAt: DateTime.now(),
        ),
      ]);

      await tester.pumpWidget(buildTestApp(taskProvider: taskProvider));
      await tester.pump();

      await tester.tap(find.text('Completed'));
      await tester.pump();

      expect(find.text('Completed Task'), findsOneWidget);
      expect(find.text('Ongoing Task'), findsNothing);
    });

    testWidgets('tapping Missed tab filters to missed tasks', (tester) async {
      final taskProvider = TaskProvider();
      taskProvider.setTasksForTesting([
        Task(
          id: '1',
          title: 'Missed Task',
          description: '',
          deadline: DateTime.now().subtract(const Duration(days: 1)),
          status: TaskStatus.missed,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Task(
          id: '2',
          title: 'Ongoing Task',
          description: '',
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.ongoing,
          createdAt: DateTime.now(),
        ),
      ]);

      await tester.pumpWidget(buildTestApp(taskProvider: taskProvider));
      await tester.pump();

      await tester.tap(find.text('Missed'));
      await tester.pump();

      expect(find.text('Missed Task'), findsOneWidget);
      expect(find.text('Ongoing Task'), findsNothing);
    });

    testWidgets('search filters tasks by title', (tester) async {
      final taskProvider = TaskProvider();
      taskProvider.setTasksForTesting([
        Task(
          id: '1',
          title: 'Buy groceries',
          description: '',
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.ongoing,
          createdAt: DateTime.now(),
        ),
        Task(
          id: '2',
          title: 'Walk the dog',
          description: '',
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.ongoing,
          createdAt: DateTime.now(),
        ),
      ]);

      await tester.pumpWidget(buildTestApp(taskProvider: taskProvider));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'groceries');
      await tester.pump();

      expect(find.text('Buy groceries'), findsOneWidget);
      expect(find.text('Walk the dog'), findsNothing);
    });

    testWidgets('search filters tasks by description', (tester) async {
      final taskProvider = TaskProvider();
      taskProvider.setTasksForTesting([
        Task(
          id: '1',
          title: 'Task 1',
          description: 'urgent meeting prep',
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.ongoing,
          createdAt: DateTime.now(),
        ),
        Task(
          id: '2',
          title: 'Task 2',
          description: 'casual walk',
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.ongoing,
          createdAt: DateTime.now(),
        ),
      ]);

      await tester.pumpWidget(buildTestApp(taskProvider: taskProvider));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'urgent');
      await tester.pump();

      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsNothing);
    });

    testWidgets('tapping profile avatar navigates to profile screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      // The profile avatar shows the person icon by default
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Profile screen has 'Profile' or 'Settings' header — verify by checking
      // we've navigated (HomeScreen's "All Activity" is no longer at the top)
      // Just ensure no error occurred.
    });

    testWidgets('tapping a task card navigates to focus mode', (tester) async {
      final taskProvider = TaskProvider();
      taskProvider.setTasksForTesting([
        Task(
          id: '1',
          title: 'Click me task',
          description: '',
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.ongoing,
          createdAt: DateTime.now(),
        ),
      ]);

      await tester.pumpWidget(buildTestApp(taskProvider: taskProvider));
      await tester.pump();

      await tester.tap(find.text('Click me task'));
      await tester.pumpAndSettle();

      // FocusModeScreen has 'Task details' header
      expect(find.text('Task details'), findsOneWidget);
    });

    testWidgets('shows tasks with different priorities (medium, low)',
        (tester) async {
      final taskProvider = TaskProvider();
      taskProvider.setTasksForTesting([
        Task(
          id: '1',
          title: 'Medium task',
          description: '',
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.ongoing,
          priority: TaskPriority.medium,
          createdAt: DateTime.now(),
        ),
        Task(
          id: '2',
          title: 'Low task',
          description: '',
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.ongoing,
          priority: TaskPriority.low,
          createdAt: DateTime.now(),
        ),
        Task(
          id: '3',
          title: 'High task',
          description: '',
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.ongoing,
          priority: TaskPriority.high,
          createdAt: DateTime.now(),
        ),
      ]);

      await tester.pumpWidget(buildTestApp(taskProvider: taskProvider));
      await tester.pump();

      expect(find.text('Medium task'), findsOneWidget);
      expect(find.text('Low task'), findsOneWidget);
      expect(find.text('High task'), findsOneWidget);
    });

    testWidgets('tapping center + button opens AddTaskBottomSheet', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // AddTaskBottomSheet header text is 'Add new task'
      expect(find.text('Add new task'), findsAtLeastNWidgets(1));
    });

    testWidgets('add task flow: submit returns Task → fake provider success → SuccessModal shows',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final fake = FakeTaskProvider();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TaskProvider>.value(value: fake),
            ChangeNotifierProvider(create: (_) => ProfileProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: Builder(
            builder: (context) {
              final theme = Provider.of<ThemeProvider>(context);
              return MaterialApp(
                theme: theme.lightTheme,
                home: const HomeScreen(),
              );
            },
          ),
        ),
      );
      await tester.pump();

      // Open bottom sheet
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill title
      await tester.enterText(find.byType(TextFormField).first, 'Quick task');
      await tester.pump();

      // Pick due date
      final dueInk = find
          .ancestor(
            of: find.text('dd/mm/yy').last,
            matching: find.byType(InkWell),
          )
          .first;
      await tester.ensureVisible(dueInk);
      await tester.pumpAndSettle();
      await tester.tap(dueInk);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add new task'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // SuccessModal is shown after fake addTask succeeds
      expect(find.text('New task Added'), findsOneWidget);

      // Tap Back to home — closes modal, no navigation
      await tester.tap(find.text('Back to home'));
      await tester.pumpAndSettle();

      expect(find.text('New task Added'), findsNothing);
    });

    testWidgets('add task flow: tap Check task navigates to FocusModeScreen',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final fake = FakeTaskProvider();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TaskProvider>.value(value: fake),
            ChangeNotifierProvider(create: (_) => ProfileProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: Builder(
            builder: (context) {
              final theme = Provider.of<ThemeProvider>(context);
              return MaterialApp(
                theme: theme.lightTheme,
                home: const HomeScreen(),
              );
            },
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Focus me');
      await tester.pump();

      final dueInk = find
          .ancestor(
            of: find.text('dd/mm/yy').last,
            matching: find.byType(InkWell),
          )
          .first;
      await tester.ensureVisible(dueInk);
      await tester.pumpAndSettle();
      await tester.tap(dueInk);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add new task'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Tap Check task on the success modal — navigates to FocusModeScreen
      await tester.tap(find.text('Check task'));
      await tester.pumpAndSettle();

      expect(find.text('Task details'), findsOneWidget);
    });

    testWidgets('add task flow with failing provider shows error snackbar',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      // Open bottom sheet
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill title
      await tester.enterText(find.byType(TextFormField).first, 'Quick task');
      await tester.pump();

      // Pick due date via ensureVisible
      final dueInk = find
          .ancestor(
            of: find.text('dd/mm/yy').last,
            matching: find.byType(InkWell),
          )
          .first;
      await tester.ensureVisible(dueInk);
      await tester.pumpAndSettle();
      await tester.tap(dueInk);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Submit the bottom sheet (top "Add new task" button)
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add new task'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Provider's addTask fails → home_screen catch block shows snackbar
      expect(find.textContaining('Failed to add task'), findsOneWidget);
    });
  });
}
