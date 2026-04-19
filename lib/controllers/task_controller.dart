import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskController extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> tasks = [];
  bool isLoading = false;

  Future<void> loadTasks() async {
    isLoading = true;
    notifyListeners();

    try {
      tasks = await _taskService.getTasks();
    } catch (e) {
      debugPrint("Erro ao carregar tarefas: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final newTask = await _taskService.createTask(task);
      tasks.add(newTask);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleStatus(int index) async {
    try {
      await _taskService.toggleTaskStatus(tasks[index].id!);
      tasks[index] = tasks[index].copyWith(completed: !tasks[index].completed);
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao alternar status: $e");
    }
  }

  Future<void> removeTask(int index) async {
    try {
      await _taskService.deleteTask(tasks[index].id!);
      tasks.removeAt(index);
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao deletar: $e");
    }
  }
}