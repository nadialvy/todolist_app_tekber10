import 'package:todolist_app_tekber10/models/task.dart';
import 'package:todolist_app_tekber10/providers/task_provider.dart';

/// TaskProvider subclass that short-circuits Supabase calls so widget tests
/// can exercise the success branches of consumers (e.g. SnackBar after
/// markAsCompleted, Navigator.pop after deleteTask, success modal after
/// addTask).
class FakeTaskProvider extends TaskProvider {
  @override
  Future<Task> addTask(Task task) async {
    setTasksForTesting([...allTasks, task]);
    return task;
  }

  @override
  Future<void> updateTask(String id, Task updatedTask) async {
    final current = [...allTasks];
    final index = current.indexWhere((t) => t.id == id);
    if (index != -1) {
      current[index] = updatedTask;
      setTasksForTesting(current);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    setTasksForTesting(allTasks.where((t) => t.id != id).toList());
  }

  @override
  Future<void> deleteTasks(List<String> ids) async {
    setTasksForTesting(allTasks.where((t) => !ids.contains(t.id)).toList());
  }

  @override
  Future<void> markAsCompleted(String id) async {
    final current = [...allTasks];
    final index = current.indexWhere((t) => t.id == id);
    if (index != -1) {
      current[index].status = TaskStatus.completed;
      current[index].completedAt = DateTime.now();
      setTasksForTesting(current);
    }
  }

  @override
  Future<void> loadTasks() async {
    // No-op: tests set tasks via setTasksForTesting.
  }
}
