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

  void _confirmDelete(BuildContext context, int taskId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Apagar Tarefa"),
        content: const Text("Deseja mesmo remover esta tarefa?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Não")),
          TextButton(
            onPressed: () {
              _taskService.deleteTask(taskId);
              Navigator.pop(ctx);
            }, 
            child: const Text("Sim", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  final TaskService _taskService = TaskService();
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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  isThreeLine: true,
                  leading: Checkbox(
                    value: task.completed,
                    onChanged: (bool? newValue) async {
                      if (newValue != null && task.id != null) {
                        try {
                          await _taskService.toggleTaskStatus(task.id!);                        
                          setState(() {
                            _refreshTasks(); 
                          });
                        } catch (e) {
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
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),  
                    onPressed: () => _confirmDelete(context, task.id!),
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
            _refreshTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}