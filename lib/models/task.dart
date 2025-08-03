class Task {
  final int id;
  final String title;
  final String description;
  bool completed;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.completed = false,
    required this.createdAt,
  });

  // Factory constructor for creating Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['body'] ?? json['description'] ?? '',
      completed: json['completed'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': description,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Copy method for updating task properties
  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}