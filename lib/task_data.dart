class Task {
  String title;
  DateTime dueDate;
  String priority;
  String category;
  bool isCompleted;

  Task({
    required this.title,
    required this.dueDate,
    required this.priority,
    required this.category,
    this.isCompleted = false,
  });
}

class TaskData {
  static List<Task> tasks = [];

  static List<String> categories = [
    'General',
    'Study',
    'Work',
    'Personal',
  ];

  static void addCategory(String categoryName) {
    if (!categories.contains(categoryName)) {
      categories.add(categoryName);
    }
  }
}