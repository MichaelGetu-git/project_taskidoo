class Task {
  String id;
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  String assignedTo; // User ID of the assigned person

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.assignedTo,
  });
}
