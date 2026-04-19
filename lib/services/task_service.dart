import '../models/task.dart';
import '../api/api_client.dart';

class TaskService {
  final _dio = apiClient.dio;

  Future<List<Task>> getTasks() async {
    try {
      final response = await _dio.get('/api/tasks');
      final List<dynamic> data = response.data;
      return data.map((item) => Task.responseJson(item)).toList();
    } catch (e) {
      throw Exception("Falha ao carregar tarefas: $e");
    }
  }

  Future<Task> createTask(Task task) async {
    final response = await _dio.post('/api/tasks', data: task.toResquest());
    return Task.responseJson(response.data);
  }

  Future<void> toggleTaskStatus(int id) async {
    await _dio.patch('/api/tasks/$id/completed');
  }

  Future<void> deleteTask(int id) async {
    await _dio.delete('/api/tasks/$id');
  }
}