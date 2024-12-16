class ToDo {
  String name;
  String description;
  String priority;
  DateTime? date;
  bool isCompleted;
  String? startTime; // Start time
  String? endTime;   // End time

  // Constructor to initialize ToDo instance
  ToDo({
    required this.name,
    required this.description,
    required this.priority,
    this.date,
    this.isCompleted = false,
    this.startTime,
    this.endTime,
  });

  // Method to update the ToDo details
  ToDo updateToDo({
    String? title,
    String? description,
    String? priority,
    DateTime? date,
    bool? isCompleted,
    String? startTime,
    String? endTime,
  }) {
    // Validate priority input (assuming valid options are 'Low', 'Medium', 'High')
    String validPriority = _validatePriority(priority);

    return ToDo(
      name: title ?? this.name,
      description: description ?? this.description,
      priority: validPriority,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  // Helper method to ensure priority is valid
  String _validatePriority(String? priority) {
    const validPriorities = ['Low', 'Medium', 'High'];
    return priority != null && validPriorities.contains(priority)
        ? priority
        : this.priority;  // Default to the existing priority if invalid
  }

  @override
  String toString() {
    return 'ToDo{name: $name, description: $description, priority: $priority, date: $date, isCompleted: $isCompleted, startTime: $startTime, endTime: $endTime}';
  }
}
