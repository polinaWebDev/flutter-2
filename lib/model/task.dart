typedef JsonMap = Map<String, dynamic>;

enum Priority {
  low('Низкая'),
  medium('Средняя'),
  high('Высокая');

  final String label;
  const Priority(this.label);
}

class Task {
  String title;
  bool isDone;
  Priority priority;
  final DateTime createdAt;

  Task({
    required this.title,
    this.isDone = false,
    this.priority = Priority.medium,
    required this.createdAt,
  });

  JsonMap toJson() => {
    'title': title,
    'isDone': isDone,
    'priority': priority.index,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory Task.fromJson(JsonMap json) => Task(
    title: json['title'],
    isDone: json['isDone'],
    priority: Priority.values[json['priority']],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
  );
}
