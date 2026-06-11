import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist_app_tekber10/models/task.dart';
import 'package:todolist_app_tekber10/providers/task_provider.dart';
import 'package:todolist_app_tekber10/providers/profile_provider.dart';
import 'package:todolist_app_tekber10/providers/theme_provider.dart';
import 'package:todolist_app_tekber10/screens/home_screen.dart';

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
      expect(find.text('Search New Task Here'), findsOneWidget);
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
  });
}
