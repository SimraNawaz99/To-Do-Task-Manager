class Task {
  int id;
  String title;
  DateTime dueDate;
  String priority;
  String category;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.priority,
    required this.category,
    this.isCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      dueDate: DateTime.parse(json['due_date'].toString()),
      priority: json['priority']?.toString() ?? 'Medium',
      category: json['category']?.toString() ?? 'General',
      isCompleted:
      json['is_completed'] == 1 ||
          json['is_completed'] == true ||
          json['is_completed'].toString() == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'due_date': formattedDueDate,
      'priority': priority,
      'category': category,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  String get formattedDueDate {
    final year = dueDate.year.toString();
    final month = dueDate.month.toString().padLeft(2, '0');
    final day = dueDate.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}