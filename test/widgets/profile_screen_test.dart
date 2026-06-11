import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist_app_tekber10/models/task.dart';
import 'package:todolist_app_tekber10/models/user_profile.dart';
import 'package:todolist_app_tekber10/providers/task_provider.dart';
import 'package:todolist_app_tekber10/providers/profile_provider.dart';
import 'package:todolist_app_tekber10/providers/theme_provider.dart';
import 'package:todolist_app_tekber10/screens/profile_screen.dart';

Widget buildTestApp({
  TaskProvider? taskProvider,
  ProfileProvider? profileProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: taskProvider ?? TaskProvider()),
      ChangeNotifierProvider.value(value: profileProvider ?? ProfileProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: Builder(
      builder: (ctx) {
        final tp = Provider.of<ThemeProvider>(ctx);
        return MaterialApp(
          theme: tp.lightTheme,
          home: const ProfileScreen(),
        );
      },
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProfileScreen', () {
    testWidgets('should render Profile AppBar title', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('should render default user name', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('User'), findsOneWidget);
    });

    testWidgets('should render custom user name from ProfileProvider', (tester) async {
      final profileProvider = ProfileProvider();
      profileProvider.profile.name = 'Alice Smith';

      await tester.pumpWidget(buildTestApp(profileProvider: profileProvider));
      await tester.pump();

      expect(find.text('Alice Smith'), findsOneWidget);
    });

    testWidgets('should show No age set when age is null', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('No age set'), findsOneWidget);
    });

    testWidgets('should show age when profile has age', (tester) async {
      final profileProvider = ProfileProvider();
      profileProvider.profile.age = 22;

      await tester.pumpWidget(buildTestApp(profileProvider: profileProvider));
      await tester.pump();

      expect(find.text('22 years old'), findsOneWidget);
    });

    testWidgets('should render Edit profile button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Edit profile'), findsOneWidget);
    });

    testWidgets('should render Logout button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('should render back button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should render person icon when no photo set', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      expect(find.byIcon(Icons.person), findsWidgets);
    });

    testWidgets('should show completed task count', (tester) async {
      final taskProvider = TaskProvider();
      taskProvider.setTasksForTesting([
        Task(
          id: '1',
          title: 'Done 1',
          description: '',
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.completed,
          createdAt: DateTime.now(),
        ),
        Task(
          id: '2',
          title: 'Done 2',
          description: '',
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.completed,
          createdAt: DateTime.now(),
        ),
      ]);

      await tester.pumpWidget(buildTestApp(taskProvider: taskProvider));
      await tester.pump();

      expect(find.text('2'), findsWidgets);
    });

    testWidgets('should render weekly stats section', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();
      // Weekly stats shows day labels
      expect(find.text('Mon'), findsOneWidget);
    });
  });
}
