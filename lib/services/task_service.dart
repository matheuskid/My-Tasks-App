import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskService { 
  
  static const String baseUrl = String.fromEnvironment(
    'API_URL', 
    defaultValue: 'http://localhost:8080'
  );

  // GET: Buscar todas as tarefas
  Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    String? jwt = prefs.getString('jwt_token');
    final response = await http.get(Uri.parse('$baseUrl/api/tasks'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwt",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Task.responseJson(item)).toList();
    } else {
      throw Exception("Falha ao carregar tarefas");
    }
  }

  // POST: Criar nova tarefa
  Future<Task> createTask(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    String? jwt = prefs.getString('jwt_token');
    final response = await http.post(
      Uri.parse('$baseUrl/api/tasks'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwt",
        },
      body: jsonEncode(task.toResquest()),
    );

    if (response.statusCode == 201) {
      return Task.responseJson(jsonDecode(response.body));
    } else {
      throw Exception("Falha ao criar tarefa");
    }
  }

  Future<void> toggleTaskStatus(int id) async {
    final prefs = await SharedPreferences.getInstance();
    String? jwt = prefs.getString('jwt_token');
    final response = await http.patch(
      Uri.parse('$baseUrl/api/tasks/$id/completed'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $jwt",
        },
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar status');
    }
  }
}