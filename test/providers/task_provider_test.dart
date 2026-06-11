import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_app_tekber10/models/task.dart';
import 'package:todolist_app_tekber10/providers/task_provider.dart';

Task _makeTask({
  required String id,
  required String title,
  required TaskStatus status,
  required DateTime deadline,
  TaskPriority priority = TaskPriority.medium,
  DateTime? completedAt,
  DateTime? createdAt,
}) {
  return Task(
    id: id,
    title: title,
    description: '',
    deadline: deadline,
    status: status,
    priority: priority,
    createdAt: createdAt ?? DateTime.now().subtract(const Duration(days: 1)),
    completedAt: completedAt,
  );
}

void main() {
  group('WeeklyStats', () {
    test('should create WeeklyStats with correct values', () {
      final stats = WeeklyStats(
        dailyCounts: [1, 2, 3, 0, 5, 2, 1],
        progress: 25.0,
        maxCount: 5,
      );

      expect(stats.dailyCounts.length, 7);
      expect(stats.progress, 25.0);
      expect(stats.maxCount, 5);
    });

    test('should have 7 days in dailyCounts', () {
      final stats = WeeklyStats(
        dailyCounts: [0, 0, 0, 0, 0, 0, 0],
        progress: 0.0,
        maxCount: 1,
      );

      expect(stats.dailyCounts.length, 7);
    });

    test('should handle negative progress (fewer tasks than last week)', () {
      final stats = WeeklyStats(
        dailyCounts: [1, 0, 0, 0, 0, 0, 0],
        progress: -50.0,
        maxCount: 1,
      );

      expect(stats.progress, -50.0);
    });

    test('should handle 100% progress (no tasks last week, some this week)', () {
      final stats = WeeklyStats(
        dailyCounts: [2, 3, 1, 0, 0, 0, 0],
        progress: 100.0,
        maxCount: 3,
      );

      expect(stats.progress, 100.0);
    });
  });

  group('TaskProvider Filtering and Sorting', () {
    // Helper function to create test tasks
    Task createTestTask({
      required String id,
      required String title,
      required TaskStatus status,
      required DateTime deadline,
      TaskPriority priority = TaskPriority.medium,
      DateTime? completedAt,
      DateTime? createdAt,
    }) {
      return Task(
        id: id,
        title: title,
        description: '',
        deadline: deadline,
        status: status,
        priority: priority,
        createdAt: createdAt ?? DateTime.now().subtract(const Duration(days: 1)),
        completedAt: completedAt,
      );
    }

    group('ongoingTasks getter', () {
      test('should filter and return only ongoing tasks', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(id: '1', title: 'Ongoing 1', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 1))),
          createTestTask(id: '2', title: 'Completed', status: TaskStatus.completed, deadline: now),
          createTestTask(id: '3', title: 'Ongoing 2', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 2))),
          createTestTask(id: '4', title: 'Missed', status: TaskStatus.missed, deadline: now.subtract(const Duration(days: 1))),
        ]);

        final ongoingTasks = provider.ongoingTasks;

        expect(ongoingTasks.length, 2);
        expect(ongoingTasks.every((t) => t.status == TaskStatus.ongoing), true);
        expect(ongoingTasks.map((t) => t.title).toList(), containsAll(['Ongoing 1', 'Ongoing 2']));
      });

      test('should sort ongoing tasks by deadline ascending', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(
            id: '1',
            title: 'Later Task',
            status: TaskStatus.ongoing,
            deadline: now.add(const Duration(days: 7)),
          ),
          createTestTask(
            id: '2',
            title: 'Sooner Task',
            status: TaskStatus.ongoing,
            deadline: now.add(const Duration(days: 1)),
          ),
          createTestTask(
            id: '3',
            title: 'Middle Task',
            status: TaskStatus.ongoing,
            deadline: now.add(const Duration(days: 3)),
          ),
        ]);

        final ongoingTasks = provider.ongoingTasks;

        expect(ongoingTasks.length, 3);
        expect(ongoingTasks[0].title, 'Sooner Task');
        expect(ongoingTasks[1].title, 'Middle Task');
        expect(ongoingTasks[2].title, 'Later Task');
      });

      test('should return empty list when no ongoing tasks', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(id: '1', title: 'Completed', status: TaskStatus.completed, deadline: now),
          createTestTask(id: '2', title: 'Missed', status: TaskStatus.missed, deadline: now.subtract(const Duration(days: 1))),
        ]);

        expect(provider.ongoingTasks, isEmpty);
      });
    });

    group('completedTasks getter', () {
      test('should filter and return only completed tasks', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(id: '1', title: 'Ongoing', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 1))),
          createTestTask(id: '2', title: 'Completed 1', status: TaskStatus.completed, deadline: now, completedAt: now),
          createTestTask(id: '3', title: 'Completed 2', status: TaskStatus.completed, deadline: now, completedAt: now),
          createTestTask(id: '4', title: 'Missed', status: TaskStatus.missed, deadline: now.subtract(const Duration(days: 1))),
        ]);

        final completedTasks = provider.completedTasks;

        expect(completedTasks.length, 2);
        expect(completedTasks.every((t) => t.status == TaskStatus.completed), true);
        expect(completedTasks.map((t) => t.title).toList(), containsAll(['Completed 1', 'Completed 2']));
      });

      test('should sort completed tasks by completedAt descending (most recent first)', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(
            id: '1',
            title: 'Completed First',
            status: TaskStatus.completed,
            deadline: now,
            completedAt: now.subtract(const Duration(days: 2)),
          ),
          createTestTask(
            id: '2',
            title: 'Completed Last',
            status: TaskStatus.completed,
            deadline: now,
            completedAt: now,
          ),
          createTestTask(
            id: '3',
            title: 'Completed Middle',
            status: TaskStatus.completed,
            deadline: now,
            completedAt: now.subtract(const Duration(days: 1)),
          ),
        ]);

        final completedTasks = provider.completedTasks;

        expect(completedTasks.length, 3);
        expect(completedTasks[0].title, 'Completed Last');
        expect(completedTasks[1].title, 'Completed Middle');
        expect(completedTasks[2].title, 'Completed First');
      });

      test('should use createdAt when completedAt is null', () {
        final provider = TaskProvider();
        final now = DateTime.now();
        final earlier = now.subtract(const Duration(days: 3));
        final later = now.subtract(const Duration(days: 1));

        provider.setTasksForTesting([
          createTestTask(
            id: '1',
            title: 'Earlier Task',
            status: TaskStatus.completed,
            deadline: now,
            completedAt: null,
            createdAt: earlier,
          ),
          createTestTask(
            id: '2',
            title: 'Later Task',
            status: TaskStatus.completed,
            deadline: now,
            completedAt: null,
            createdAt: later,
          ),
        ]);

        final completedTasks = provider.completedTasks;

        expect(completedTasks.length, 2);
        expect(completedTasks[0].title, 'Later Task');
        expect(completedTasks[1].title, 'Earlier Task');
      });
    });

    group('missedTasks getter', () {
      test('should filter and return only missed tasks', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(id: '1', title: 'Ongoing', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 1))),
          createTestTask(id: '2', title: 'Completed', status: TaskStatus.completed, deadline: now),
          createTestTask(id: '3', title: 'Missed 1', status: TaskStatus.missed, deadline: now.subtract(const Duration(days: 1))),
          createTestTask(id: '4', title: 'Missed 2', status: TaskStatus.missed, deadline: now.subtract(const Duration(days: 2))),
        ]);

        final missedTasks = provider.missedTasks;

        expect(missedTasks.length, 2);
        expect(missedTasks.every((t) => t.status == TaskStatus.missed), true);
        expect(missedTasks.map((t) => t.title).toList(), containsAll(['Missed 1', 'Missed 2']));
      });

      test('should sort missed tasks by deadline ascending', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(
            id: '1',
            title: 'Later Missed',
            status: TaskStatus.missed,
            deadline: now.subtract(const Duration(days: 1)),
          ),
          createTestTask(
            id: '2',
            title: 'Earlier Missed',
            status: TaskStatus.missed,
            deadline: now.subtract(const Duration(days: 3)),
          ),
          createTestTask(
            id: '3',
            title: 'Middle Missed',
            status: TaskStatus.missed,
            deadline: now.subtract(const Duration(days: 2)),
          ),
        ]);

        final missedTasks = provider.missedTasks;

        expect(missedTasks.length, 3);
        expect(missedTasks[0].title, 'Earlier Missed');
        expect(missedTasks[1].title, 'Middle Missed');
        expect(missedTasks[2].title, 'Later Missed');
      });
    });

    group('getTaskById method', () {
      test('should find existing task by id', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(id: 'abc-123', title: 'Task A', status: TaskStatus.ongoing, deadline: now),
          createTestTask(id: 'def-456', title: 'Task B', status: TaskStatus.ongoing, deadline: now),
          createTestTask(id: 'ghi-789', title: 'Task C', status: TaskStatus.ongoing, deadline: now),
        ]);

        final found = provider.getTaskById('def-456');

        expect(found, isNotNull);
        expect(found!.title, 'Task B');
      });

      test('should return null for non-existing task id', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(id: 'abc-123', title: 'Task A', status: TaskStatus.ongoing, deadline: now),
        ]);

        final found = provider.getTaskById('non-existing');

        expect(found, isNull);
      });

      test('should return null when task list is empty', () {
        final provider = TaskProvider();

        final found = provider.getTaskById('any-id');

        expect(found, isNull);
      });
    });

    group('Task Priority filtering', () {
      test('should include tasks with different priorities in filtered results', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(id: '1', title: 'High', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 1)), priority: TaskPriority.high),
          createTestTask(id: '2', title: 'Medium', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 1)), priority: TaskPriority.medium),
          createTestTask(id: '3', title: 'Low', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 1)), priority: TaskPriority.low),
          createTestTask(id: '4', title: 'High 2', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 1)), priority: TaskPriority.high),
        ]);

        final ongoingTasks = provider.ongoingTasks;
        final highPriorityTasks = ongoingTasks.where((t) => t.priority == TaskPriority.high).toList();

        expect(ongoingTasks.length, 4);
        expect(highPriorityTasks.length, 2);
        expect(highPriorityTasks.map((t) => t.title).toList(), containsAll(['High', 'High 2']));
      });
    });
  });

  group('String to Enum Mapping (loadTasks logic)', () {
    // Helper function that replicates the exact JSON-to-Task mapping logic from TaskProvider.loadTasks
    // This tests the same mapping logic that loadTasks uses when converting Supabase JSON responses to Task objects
    Task taskFromSupabaseJson(Map<String, dynamic> json) {
      // Map string status dari Supabase ke enum (same logic as loadTasks)
      TaskStatus status;
      switch (json['status']) {
        case 'ongoing':
          status = TaskStatus.ongoing;
          break;
        case 'completed':
          status = TaskStatus.completed;
          break;
        case 'missed':
          status = TaskStatus.missed;
          break;
        default:
          status = TaskStatus.ongoing;
      }

      // Map string priority dari Supabase ke enum (same logic as loadTasks)
      TaskPriority priority;
      switch (json['priority']) {
        case 'low':
          priority = TaskPriority.low;
          break;
        case 'medium':
          priority = TaskPriority.medium;
          break;
        case 'high':
          priority = TaskPriority.high;
          break;
        default:
          priority = TaskPriority.medium;
      }

      // Parse date dari Supabase (format: YYYY-MM-DD)
      DateTime deadline;
      if (json['due_date'] != null) {
        deadline = DateTime.parse(json['due_date']);
      } else {
        deadline = DateTime.now().add(const Duration(days: 1));
      }

      DateTime? startDate;
      if (json['start_date'] != null) {
        startDate = DateTime.parse(json['start_date']);
      }

      return Task(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        startDate: startDate,
        deadline: deadline,
        status: status,
        priority: priority,
        createdAt: DateTime.parse(json['created_at']),
        completedAt: null,
        steps: json['steps'] != null && json['steps'] is List
            ? List<Map<String, dynamic>>.from((json['steps'] as List).map((x) => x is Map ? Map<String, dynamic>.from(x) : {'step': x.toString(), 'estimatedMinutes': 10}))
            : null,
      );
    }

    test('should map "ongoing" string to TaskStatus.ongoing', () {
      final json = {
        'id': 'test-1',
        'title': 'Test Task',
        'description': 'Test',
        'status': 'ongoing',
        'priority': 'medium',
        'due_date': '2024-12-31',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final task = taskFromSupabaseJson(json);
      expect(task.status, TaskStatus.ongoing);
    });

    test('should map "completed" string to TaskStatus.completed', () {
      final json = {
        'id': 'test-2',
        'title': 'Test Task',
        'description': 'Test',
        'status': 'completed',
        'priority': 'medium',
        'due_date': '2024-12-31',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final task = taskFromSupabaseJson(json);
      expect(task.status, TaskStatus.completed);
    });

    test('should map "missed" string to TaskStatus.missed', () {
      final json = {
        'id': 'test-3',
        'title': 'Test Task',
        'description': 'Test',
        'status': 'missed',
        'priority': 'medium',
        'due_date': '2024-12-31',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final task = taskFromSupabaseJson(json);
      expect(task.status, TaskStatus.missed);
    });

    test('should default to TaskStatus.ongoing for unknown status string', () {
      final json = {
        'id': 'test-4',
        'title': 'Test Task',
        'description': 'Test',
        'status': 'unknown_status',
        'priority': 'medium',
        'due_date': '2024-12-31',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final task = taskFromSupabaseJson(json);
      expect(task.status, TaskStatus.ongoing);
    });

    test('should map "low" string to TaskPriority.low', () {
      final json = {
        'id': 'test-5',
        'title': 'Test Task',
        'description': 'Test',
        'status': 'ongoing',
        'priority': 'low',
        'due_date': '2024-12-31',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final task = taskFromSupabaseJson(json);
      expect(task.priority, TaskPriority.low);
    });

    test('should map "medium" string to TaskPriority.medium', () {
      final json = {
        'id': 'test-6',
        'title': 'Test Task',
        'description': 'Test',
        'status': 'ongoing',
        'priority': 'medium',
        'due_date': '2024-12-31',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final task = taskFromSupabaseJson(json);
      expect(task.priority, TaskPriority.medium);
    });

    test('should map "high" string to TaskPriority.high', () {
      final json = {
        'id': 'test-7',
        'title': 'Test Task',
        'description': 'Test',
        'status': 'ongoing',
        'priority': 'high',
        'due_date': '2024-12-31',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final task = taskFromSupabaseJson(json);
      expect(task.priority, TaskPriority.high);
    });

    test('should default to TaskPriority.medium for unknown priority string', () {
      final json = {
        'id': 'test-8',
        'title': 'Test Task',
        'description': 'Test',
        'status': 'ongoing',
        'priority': 'unknown_priority',
        'due_date': '2024-12-31',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final task = taskFromSupabaseJson(json);
      expect(task.priority, TaskPriority.medium);
    });

    test('should correctly map all status and priority combinations', () {
      final testCases = [
        {'status': 'ongoing', 'priority': 'low', 'expectedStatus': TaskStatus.ongoing, 'expectedPriority': TaskPriority.low},
        {'status': 'ongoing', 'priority': 'medium', 'expectedStatus': TaskStatus.ongoing, 'expectedPriority': TaskPriority.medium},
        {'status': 'ongoing', 'priority': 'high', 'expectedStatus': TaskStatus.ongoing, 'expectedPriority': TaskPriority.high},
        {'status': 'completed', 'priority': 'low', 'expectedStatus': TaskStatus.completed, 'expectedPriority': TaskPriority.low},
        {'status': 'completed', 'priority': 'high', 'expectedStatus': TaskStatus.completed, 'expectedPriority': TaskPriority.high},
        {'status': 'missed', 'priority': 'medium', 'expectedStatus': TaskStatus.missed, 'expectedPriority': TaskPriority.medium},
      ];

      for (var i = 0; i < testCases.length; i++) {
        final testCase = testCases[i];
        final json = {
          'id': 'test-$i',
          'title': 'Test Task',
          'description': 'Test',
          'status': testCase['status'],
          'priority': testCase['priority'],
          'due_date': '2024-12-31',
          'created_at': '2024-01-01T00:00:00Z',
        };

        final task = taskFromSupabaseJson(json);
        expect(task.status, testCase['expectedStatus'], reason: 'Status mapping failed for ${testCase['status']}');
        expect(task.priority, testCase['expectedPriority'], reason: 'Priority mapping failed for ${testCase['priority']}');
      }
    });

    test('should work correctly with TaskProvider when tasks are created from Supabase JSON', () {
      final provider = TaskProvider();
      final now = DateTime.now();

      // Simulate JSON responses from Supabase (as loadTasks would receive them)
      final jsonTasks = [
        {
          'id': 'task-1',
          'title': 'Ongoing High Priority',
          'description': 'Test',
          'status': 'ongoing',
          'priority': 'high',
          'due_date': now.add(const Duration(days: 1)).toIso8601String().split('T')[0],
          'created_at': now.toIso8601String(),
        },
        {
          'id': 'task-2',
          'title': 'Completed Low Priority',
          'description': 'Test',
          'status': 'completed',
          'priority': 'low',
          'due_date': now.toIso8601String().split('T')[0],
          'created_at': now.toIso8601String(),
        },
        {
          'id': 'task-3',
          'title': 'Missed Medium Priority',
          'description': 'Test',
          'status': 'missed',
          'priority': 'medium',
          'due_date': now.subtract(const Duration(days: 1)).toIso8601String().split('T')[0],
          'created_at': now.toIso8601String(),
        },
      ];

      // Convert JSON to Task objects using the same mapping logic as loadTasks
      final tasks = jsonTasks.map((json) => taskFromSupabaseJson(json)).toList();

      // Add tasks to provider using test method
      provider.setTasksForTesting(tasks);

      // Verify the provider correctly handles the mapped tasks
      expect(provider.ongoingTasks.length, 1);
      expect(provider.ongoingTasks[0].status, TaskStatus.ongoing);
      expect(provider.ongoingTasks[0].priority, TaskPriority.high);
      expect(provider.ongoingTasks[0].title, 'Ongoing High Priority');

      expect(provider.completedTasks.length, 1);
      expect(provider.completedTasks[0].status, TaskStatus.completed);
      expect(provider.completedTasks[0].priority, TaskPriority.low);
      expect(provider.completedTasks[0].title, 'Completed Low Priority');

      expect(provider.missedTasks.length, 1);
      expect(provider.missedTasks[0].status, TaskStatus.missed);
      expect(provider.missedTasks[0].priority, TaskPriority.medium);
      expect(provider.missedTasks[0].title, 'Missed Medium Priority');
    });
  });

  group('TaskProvider clearTasks', () {
    test('should remove all tasks', () {
      final provider = TaskProvider();
      final now = DateTime.now();

      provider.setTasksForTesting([
        _makeTask(id: '1', title: 'Task A', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 1))),
        _makeTask(id: '2', title: 'Task B', status: TaskStatus.completed, deadline: now),
      ]);

      expect(provider.allTasks.length, 2);

      provider.clearTasks();

      expect(provider.allTasks, isEmpty);
      expect(provider.ongoingTasks, isEmpty);
      expect(provider.completedTasks, isEmpty);
      expect(provider.missedTasks, isEmpty);
    });

    test('should be safe to call when already empty', () {
      final provider = TaskProvider();
      provider.clearTasks();
      expect(provider.allTasks, isEmpty);
    });
  });

  group('TaskProvider allTasks auto-update status', () {
    test('should auto-update ongoing task past deadline to missed', () {
      final provider = TaskProvider();

      provider.setTasksForTesting([
        Task(
          id: 'overdue',
          title: 'Overdue Task',
          description: '',
          deadline: DateTime.now().subtract(const Duration(hours: 1)),
          status: TaskStatus.ongoing,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ]);

      final tasks = provider.allTasks;
      expect(tasks[0].status, TaskStatus.missed);
    });

    test('should not change status of completed task past deadline', () {
      final provider = TaskProvider();

      provider.setTasksForTesting([
        Task(
          id: 'completed',
          title: 'Done Task',
          description: '',
          deadline: DateTime.now().subtract(const Duration(days: 1)),
          status: TaskStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ]);

      final tasks = provider.allTasks;
      expect(tasks[0].status, TaskStatus.completed);
    });

    test('should not change status of ongoing task with future deadline', () {
      final provider = TaskProvider();

      provider.setTasksForTesting([
        Task(
          id: 'future',
          title: 'Future Task',
          description: '',
          deadline: DateTime.now().add(const Duration(days: 7)),
          status: TaskStatus.ongoing,
          createdAt: DateTime.now(),
        ),
      ]);

      final tasks = provider.allTasks;
      expect(tasks[0].status, TaskStatus.ongoing);
    });
  });

  group('TaskProvider getWeeklyStats', () {
    test('should return default stats when no tasks exist', () {
      final provider = TaskProvider();
      final stats = provider.getWeeklyStats();

      expect(stats.dailyCounts.length, 7);
      expect(stats.dailyCounts.every((c) => c == 0), true);
      expect(stats.progress, 0.0);
      expect(stats.maxCount, 1);
    });

    test('should not count ongoing or missed tasks', () {
      final provider = TaskProvider();
      final now = DateTime.now();

      provider.setTasksForTesting([
        _makeTask(id: '1', title: 'Ongoing', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 1)), createdAt: now),
        _makeTask(id: '2', title: 'Missed', status: TaskStatus.missed, deadline: now.subtract(const Duration(days: 1)), createdAt: now),
      ]);

      final stats = provider.getWeeklyStats();
      expect(stats.dailyCounts.every((c) => c == 0), true);
      expect(stats.progress, 0.0);
    });

    test('should return progress 100 when current week has completed tasks and last week had none', () {
      final provider = TaskProvider();
      final now = DateTime.now();

      provider.setTasksForTesting([
        Task(
          id: '1',
          title: 'Completed This Week',
          description: '',
          deadline: now.add(const Duration(days: 1)),
          status: TaskStatus.completed,
          createdAt: now,
        ),
      ]);

      final stats = provider.getWeeklyStats();
      expect(stats.progress, 100.0);
    });

    test('should count completed tasks in correct day slot', () {
      final provider = TaskProvider();
      final now = DateTime.now();

      provider.setTasksForTesting([
        Task(id: '1', title: 'T1', description: '', deadline: now.add(const Duration(days: 1)), status: TaskStatus.completed, createdAt: now),
        Task(id: '2', title: 'T2', description: '', deadline: now.add(const Duration(days: 1)), status: TaskStatus.completed, createdAt: now),
      ]);

      final stats = provider.getWeeklyStats();
      final todayIndex = now.weekday - 1;
      expect(stats.dailyCounts[todayIndex], 2);
      expect(stats.maxCount, 2);
    });

    test('should calculate negative progress when fewer tasks than last week', () {
      final provider = TaskProvider();
      final now = DateTime.now();

      // Get a date that is safely in the previous ISO week
      final today = DateTime(now.year, now.month, now.day);
      final startOfCurrentWeek = today.subtract(Duration(days: now.weekday - 1));
      final prevWeekDate = startOfCurrentWeek.subtract(const Duration(days: 3));

      provider.setTasksForTesting([
        Task(id: '1', title: 'PW1', description: '', deadline: prevWeekDate, status: TaskStatus.completed, createdAt: prevWeekDate),
        Task(id: '2', title: 'PW2', description: '', deadline: prevWeekDate, status: TaskStatus.completed, createdAt: prevWeekDate),
      ]);

      final stats = provider.getWeeklyStats();
      expect(stats.progress, -100.0);
    });

    test('should calculate positive progress when more tasks this week than last', () {
      final provider = TaskProvider();
      final now = DateTime.now();

      final today = DateTime(now.year, now.month, now.day);
      final startOfCurrentWeek = today.subtract(Duration(days: now.weekday - 1));
      final prevWeekDate = startOfCurrentWeek.subtract(const Duration(days: 3));

      provider.setTasksForTesting([
        Task(id: 'cw1', title: 'CW1', description: '', deadline: now.add(const Duration(days: 1)), status: TaskStatus.completed, createdAt: now),
        Task(id: 'cw2', title: 'CW2', description: '', deadline: now.add(const Duration(days: 1)), status: TaskStatus.completed, createdAt: now),
        Task(id: 'pw1', title: 'PW1', description: '', deadline: prevWeekDate, status: TaskStatus.completed, createdAt: prevWeekDate),
      ]);

      final stats = provider.getWeeklyStats();
      expect(stats.progress, 100.0); // (2-1)/1 * 100 = 100%
    });

    test('maxCount should always be at least 1', () {
      final provider = TaskProvider();
      final stats = provider.getWeeklyStats();
      expect(stats.maxCount, greaterThanOrEqualTo(1));
    });
  });

  group('TaskProvider isLoading getter', () {
    test('isLoading is initially false', () {
      final provider = TaskProvider();
      expect(provider.isLoading, false);
    });
  });

  group('TaskProvider Supabase-backed methods error paths', () {
    // These methods exercise the enum-to-string switches before hitting
    // Supabase (uninitialized in tests), which then throws and is caught.

    Task makeTask({
      TaskStatus status = TaskStatus.ongoing,
      TaskPriority priority = TaskPriority.medium,
    }) {
      return Task(
        id: 'test-id',
        title: 'Test Task',
        description: 'desc',
        deadline: DateTime.now().add(const Duration(days: 1)),
        status: status,
        priority: priority,
        createdAt: DateTime.now(),
        startDate: DateTime.now(),
      );
    }

    group('addTask', () {
      test('addTask throws when Supabase is not initialized (ongoing/low)',
          () async {
        final provider = TaskProvider();
        expect(
          () => provider.addTask(
              makeTask(status: TaskStatus.ongoing, priority: TaskPriority.low)),
          throwsA(anything),
        );
      });

      test('addTask throws (completed/medium)', () async {
        final provider = TaskProvider();
        expect(
          () => provider.addTask(makeTask(
              status: TaskStatus.completed, priority: TaskPriority.medium)),
          throwsA(anything),
        );
      });

      test('addTask throws (missed/high)', () async {
        final provider = TaskProvider();
        expect(
          () => provider.addTask(
              makeTask(status: TaskStatus.missed, priority: TaskPriority.high)),
          throwsA(anything),
        );
      });

      test('addTask resets isLoading to false after error', () async {
        final provider = TaskProvider();
        try {
          await provider.addTask(makeTask());
        } catch (_) {}
        expect(provider.isLoading, false);
      });
    });

    group('updateTask', () {
      test('updateTask throws (ongoing/low)', () async {
        final provider = TaskProvider();
        expect(
          () => provider.updateTask(
              'some-id',
              makeTask(
                  status: TaskStatus.ongoing, priority: TaskPriority.low)),
          throwsA(anything),
        );
      });

      test('updateTask throws (completed/medium)', () async {
        final provider = TaskProvider();
        expect(
          () => provider.updateTask(
              'some-id',
              makeTask(
                  status: TaskStatus.completed,
                  priority: TaskPriority.medium)),
          throwsA(anything),
        );
      });

      test('updateTask throws (missed/high)', () async {
        final provider = TaskProvider();
        expect(
          () => provider.updateTask(
              'some-id',
              makeTask(
                  status: TaskStatus.missed, priority: TaskPriority.high)),
          throwsA(anything),
        );
      });

      test('updateTask resets isLoading to false after error', () async {
        final provider = TaskProvider();
        try {
          await provider.updateTask('id', makeTask());
        } catch (_) {}
        expect(provider.isLoading, false);
      });
    });

    group('deleteTask', () {
      test('deleteTask throws when Supabase is not initialized', () async {
        final provider = TaskProvider();
        expect(
          () => provider.deleteTask('some-id'),
          throwsA(anything),
        );
      });

      test('deleteTask resets isLoading to false after error', () async {
        final provider = TaskProvider();
        try {
          await provider.deleteTask('id');
        } catch (_) {}
        expect(provider.isLoading, false);
      });
    });

    group('deleteTasks', () {
      test('deleteTasks throws when Supabase is not initialized', () async {
        final provider = TaskProvider();
        expect(
          () => provider.deleteTasks(['id-1', 'id-2']),
          throwsA(anything),
        );
      });

      test('deleteTasks with empty list completes without throwing', () async {
        final provider = TaskProvider();
        // Empty list - loop body never runs, no Supabase call needed.
        await provider.deleteTasks([]);
        expect(provider.isLoading, false);
      });
    });

    group('markAsCompleted', () {
      test('markAsCompleted throws when Supabase is not initialized', () async {
        final provider = TaskProvider();
        expect(
          () => provider.markAsCompleted('some-id'),
          throwsA(anything),
        );
      });

      test('markAsCompleted resets isLoading to false after error', () async {
        final provider = TaskProvider();
        try {
          await provider.markAsCompleted('id');
        } catch (_) {}
        expect(provider.isLoading, false);
      });
    });

    group('loadTasks', () {
      test('loadTasks completes (catches error) when Supabase is not initialized',
          () async {
        final provider = TaskProvider();
        // loadTasks catches and logs without rethrowing.
        await provider.loadTasks();
        expect(provider.isLoading, false);
      });
    });
  });

  group('applyUpdatedTaskLocally', () {
    Task makeTaskFor({
      required String id,
      String title = 'T',
      TaskStatus status = TaskStatus.ongoing,
    }) {
      return Task(
        id: id,
        title: title,
        description: '',
        deadline: DateTime.now().add(const Duration(days: 1)),
        status: status,
        createdAt: DateTime.now(),
      );
    }

    test('replaces task in-place when id matches', () {
      final provider = TaskProvider();
      provider.setTasksForTesting([
        makeTaskFor(id: 'a', title: 'Original A'),
        makeTaskFor(id: 'b', title: 'Original B'),
      ]);

      final updated = makeTaskFor(id: 'a', title: 'Updated A');
      provider.applyUpdatedTaskLocally('a', updated);

      expect(provider.allTasks.firstWhere((t) => t.id == 'a').title,
          'Updated A');
      expect(provider.allTasks.firstWhere((t) => t.id == 'b').title,
          'Original B');
    });

    test('no-op when id is not found', () {
      final provider = TaskProvider();
      provider.setTasksForTesting([
        makeTaskFor(id: 'a', title: 'Original A'),
      ]);

      final phantom = makeTaskFor(id: 'missing', title: 'Phantom');
      provider.applyUpdatedTaskLocally('missing', phantom);

      expect(provider.allTasks.length, 1);
      expect(provider.allTasks.first.title, 'Original A');
    });
  });

  group('taskFromSupabaseJson', () {
    Map<String, dynamic> baseJson({
      String status = 'ongoing',
      String priority = 'medium',
      String? dueDate = '2026-12-31',
      String? startDate,
      dynamic steps,
      String? description = 'desc',
    }) {
      return {
        'id': 'json-1',
        'title': 'Test',
        'description': description,
        'status': status,
        'priority': priority,
        'due_date': dueDate,
        'start_date': startDate,
        'created_at': '2026-01-01T00:00:00Z',
        'steps': steps,
      };
    }

    test('maps all status values', () {
      expect(
        TaskProvider.taskFromSupabaseJson(baseJson(status: 'ongoing')).status,
        TaskStatus.ongoing,
      );
      expect(
        TaskProvider.taskFromSupabaseJson(baseJson(status: 'completed')).status,
        TaskStatus.completed,
      );
      expect(
        TaskProvider.taskFromSupabaseJson(baseJson(status: 'missed')).status,
        TaskStatus.missed,
      );
      expect(
        TaskProvider.taskFromSupabaseJson(baseJson(status: 'bogus')).status,
        TaskStatus.ongoing,
      );
    });

    test('maps all priority values', () {
      expect(
        TaskProvider.taskFromSupabaseJson(baseJson(priority: 'low')).priority,
        TaskPriority.low,
      );
      expect(
        TaskProvider.taskFromSupabaseJson(baseJson(priority: 'medium')).priority,
        TaskPriority.medium,
      );
      expect(
        TaskProvider.taskFromSupabaseJson(baseJson(priority: 'high')).priority,
        TaskPriority.high,
      );
      expect(
        TaskProvider.taskFromSupabaseJson(baseJson(priority: 'bogus')).priority,
        TaskPriority.medium,
      );
    });

    test('uses fallback deadline when due_date is null', () {
      final task = TaskProvider.taskFromSupabaseJson(baseJson(dueDate: null));
      // Fallback adds 1 day to "now" : verify it's in the future.
      expect(task.deadline.isAfter(DateTime.now()), true);
    });

    test('parses start_date when present', () {
      final task = TaskProvider.taskFromSupabaseJson(
          baseJson(startDate: '2026-01-15'));
      expect(task.startDate, DateTime(2026, 1, 15));
    });

    test('falls back to empty string when description is null', () {
      final task =
          TaskProvider.taskFromSupabaseJson(baseJson(description: null));
      expect(task.description, '');
    });

    test('parses steps as List of Maps', () {
      final task = TaskProvider.taskFromSupabaseJson(
        baseJson(steps: [
          {'step': 'do A', 'estimatedMinutes': 5},
        ]),
      );
      expect(task.steps, isNotNull);
      expect(task.steps!.length, 1);
      expect(task.steps!.first['step'], 'do A');
    });

    test('null steps result in null task.steps', () {
      final task = TaskProvider.taskFromSupabaseJson(baseJson(steps: null));
      expect(task.steps, isNull);
    });
  });

  group('parseSteps', () {
    test('returns null for null input', () {
      expect(TaskProvider.parseSteps(null), isNull);
    });

    test('parses list of Maps as-is', () {
      final result = TaskProvider.parseSteps([
        {'step': 'A', 'estimatedMinutes': 5},
        {'step': 'B', 'estimatedMinutes': 10},
      ]);
      expect(result, isNotNull);
      expect(result!.length, 2);
      expect(result[0]['step'], 'A');
    });

    test('parses list of Strings by stripping JSON chars', () {
      final result = TaskProvider.parseSteps(['{"step":"clean"}', 'bare step']);
      expect(result, isNotNull);
      expect(result!.length, 2);
      // {} and " chars stripped
      expect(result[0]['step'], contains('clean'));
      expect(result[0]['estimatedMinutes'], 10);
    });

    test('parses list of non-string non-map values via toString()', () {
      final result = TaskProvider.parseSteps([42, true]);
      expect(result, isNotNull);
      expect(result!.length, 2);
      expect(result[0]['step'], '42');
      expect(result[1]['step'], 'true');
    });

    test('parses JSON-encoded string of list', () {
      final result = TaskProvider.parseSteps('[{"step":"A","estimatedMinutes":3}]');
      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0]['step'], 'A');
    });

    test('returns null for invalid JSON string', () {
      final result = TaskProvider.parseSteps('not-json-{{');
      expect(result, isNull);
    });

    test('returns null for non-list non-string input', () {
      expect(TaskProvider.parseSteps(42), isNull);
      expect(TaskProvider.parseSteps({'a': 1}), isNull);
    });
  });
}