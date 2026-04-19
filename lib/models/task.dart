class Task {
  final int? id;
  final String title;
  final String description;
  final bool completed;
  final DateTime dueDate;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.completed = false,
    required this.dueDate
  });

  Task copyWith({bool? completed}) {
    return Task(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      completed: completed ?? this.completed,
    );
  }

  factory Task.responseJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      completed: json['completed'] ?? false,
      dueDate: DateTime.parse(json['dueDate'])
    );
  }

  Map<String, dynamic> toResquest() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String().split('T')[0], // Envia apenas YYYY-MM-DD
    };
  }
}