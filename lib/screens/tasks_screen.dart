import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import 'add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskService _taskService = TaskService();
  
  // Guardamos o future em uma variável para o FutureBuilder não 
  // disparar um novo GET toda vez que a tela redesenhar por outro motivo
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  void _refreshTasks() {
    setState(() {
      _tasksFuture = _taskService.getTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Erro de conexão: Verifique se o servidor está online.\n\n${snapshot.error}'),
              ),
            );
          } 
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma tarefa encontrada.'));
          }

          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card( // Adicionado um Card para ficar mais visível
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  isThreeLine: true,
                  leading: Checkbox(
                    value: task.completed,
                    onChanged: (bool? newValue) async {
                      if (newValue != null && task.id != null) {
                        try {
                          // 1. Chama a API Java para atualizar no banco (MySQL/H2)
                          await _taskService.toggleTaskStatus(task.id!);
                          
                          // 2. Se a API respondeu OK, atualizamos a interface (UI)
                          setState(() {
                            // Isso recarrega o FutureBuilder e mostra o check marcado
                            _refreshTasks(); 
                          });
                        } catch (e) {
                          // Se o Spring Boot estiver fora ou der erro de rede
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Erro ao sincronizar: $e")),
                          );
                        }
                      }
                    },
                  ),
                  title: Text(
                    task.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.description),
                      const SizedBox(height: 4),
                      Text(
                        "Data: ${task.dueDate.day.toString().padLeft(2, "0")}/${task.dueDate.month.toString().padLeft(2, "0")}/${task.dueDate.year}",
                        style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bool? refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );

          if (refresh == true) {
            _refreshTasks(); // Atualiza a lista chamando a API novamente
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}