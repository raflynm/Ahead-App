class Plan {
  final String name;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String location;
  final  String priority;

  // Optional fields for priority (or any other future fields)


  Plan({
    required this.name,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
 required this.priority,  // Add priority as an optional field
  });

  // Method to update the Plan details
  Plan updatePlan({
    String? name,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? location,
    String? priority,
  }) {
    return Plan(
      name: name ?? this.name,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      priority: priority ?? this.priority,
    );
  }
}
