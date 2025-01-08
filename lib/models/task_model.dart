class TaskModel {
  final String id;
  final String eventId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String assignedTo;
  final bool isCompleted;

  TaskModel({
    required this.id,
    required this.eventId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.assignedTo,
    this.isCompleted = false,
  });

  TaskModel copyWith({
    String? id,
    String? eventId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? assignedTo,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      assignedTo: assignedTo ?? this.assignedTo,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'assignedTo': assignedTo,
      'isCompleted': isCompleted,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      eventId: json['eventId'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      assignedTo: json['assignedTo'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}