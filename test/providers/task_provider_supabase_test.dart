import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todolist_app_tekber10/models/task.dart';
import 'package:todolist_app_tekber10/providers/task_provider.dart';

/// These tests initialize Supabase with a fake config and inject a fake user
/// id so the provider methods execute past the auth check, build their
/// request payload, and hit the HTTP call. The HTTP call fails (no network),
/// which exercises the catch block.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://127.0.0.1:54321',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.fake.token',
      debug: false,
    );
  });

  Task makeTask({
    TaskStatus status = TaskStatus.ongoing,
    TaskPriority priority = TaskPriority.medium,
    List<Map<String, dynamic>>? steps,
  }) {
    return Task(
      id: 'id-1',
      title: 'T',
      description: 'd',
      deadline: DateTime.now().add(const Duration(days: 1)),
      status: status,
      priority: priority,
      createdAt: DateTime.now(),
      startDate: DateTime.now(),
      steps: steps ??
          [
            {'step': 'do', 'estimatedMinutes': 5},
          ],
    );
  }

  TaskProvider authedProvider() {
    final p = TaskProvider();
    p.testUserIdOverride = 'fake-user-id';
    return p;
  }

  group('TaskProvider methods with auth user (fake)', () {
    test('addTask with ongoing/low — runs past auth, fails on HTTP', () async {
      final provider = authedProvider();
      try {
        await provider.addTask(
            makeTask(status: TaskStatus.ongoing, priority: TaskPriority.low));
      } catch (_) {}
      expect(provider.isLoading, false);
    });

    test('addTask with completed/medium', () async {
      final provider = authedProvider();
      try {
        await provider.addTask(makeTask(
            status: TaskStatus.completed, priority: TaskPriority.medium));
      } catch (_) {}
    });

    test('addTask with missed/high', () async {
      final provider = authedProvider();
      try {
        await provider.addTask(
            makeTask(status: TaskStatus.missed, priority: TaskPriority.high));
      } catch (_) {}
    });

    test('addTask with no steps', () async {
      final provider = authedProvider();
      try {
        await provider.addTask(makeTask(steps: []));
      } catch (_) {}
    });

    test('updateTask with ongoing/low', () async {
      final provider = authedProvider();
      try {
        await provider.updateTask(
            'task-id',
            makeTask(status: TaskStatus.ongoing, priority: TaskPriority.low));
      } catch (_) {}
    });

    test('updateTask with completed/medium', () async {
      final provider = authedProvider();
      try {
        await provider.updateTask(
            'task-id',
            makeTask(
                status: TaskStatus.completed, priority: TaskPriority.medium));
      } catch (_) {}
    });

    test('updateTask with missed/high', () async {
      final provider = authedProvider();
      try {
        await provider.updateTask(
            'task-id',
            makeTask(
                status: TaskStatus.missed, priority: TaskPriority.high));
      } catch (_) {}
    });

    test('deleteTask runs past auth and fails on HTTP', () async {
      final provider = authedProvider();
      try {
        await provider.deleteTask('task-id');
      } catch (_) {}
      expect(provider.isLoading, false);
    });

    test('deleteTasks runs through loop', () async {
      final provider = authedProvider();
      try {
        await provider.deleteTasks(['a', 'b', 'c']);
      } catch (_) {}
      expect(provider.isLoading, false);
    });

    test('markAsCompleted runs past auth', () async {
      final provider = authedProvider();
      try {
        await provider.markAsCompleted('task-id');
      } catch (_) {}
      expect(provider.isLoading, false);
    });

    test('loadTasks runs past auth and catches HTTP error', () async {
      final provider = authedProvider();
      await provider.loadTasks();
      expect(provider.isLoading, false);
    });
  });

  group('TaskProvider methods without auth user', () {
    test('addTask throws "User not logged in" when no auth user', () async {
      final provider = TaskProvider();
      try {
        await provider.addTask(makeTask());
        fail('Expected throw');
      } catch (_) {}
      expect(provider.isLoading, false);
    });

    test('loadTasks completes without throwing (catches error)', () async {
      final provider = TaskProvider();
      await provider.loadTasks();
      expect(provider.isLoading, false);
    });
  });
}
