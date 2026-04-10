import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _taskService = TaskService();
  
  bool _isLoading = false;
  
  // Inicializamos com a data de hoje para evitar o erro de "not initialized"
  DateTime _selectedDate = DateTime.now();

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // Impede selecionar datas passadas para novas tasks
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveTask() async {
    setState(() => _isLoading = true);

    // Criando o objeto Task (que usará o toRequest() para o seu DTO Java)
    final newTask = Task(
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _selectedDate
    );

    try {
      await _taskService.createTask(newTask);
      if (mounted) Navigator.pop(context, true); 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar no Spring Boot: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Tarefa'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView( // Evita erro de layout quando o teclado abre
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Seletor de Data estilizado
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: const Icon(Icons.calendar_today),
                      title: const Text("Data de Vencimento"),
                      subtitle: Text(
                        "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}",
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                      trailing: TextButton(
                        onPressed: _presentDatePicker,
                        child: const Text("ALTERAR"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading 
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _saveTask,
                    icon: const Icon(Icons.save),
                    label: const Text('SALVAR TAREFA', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}