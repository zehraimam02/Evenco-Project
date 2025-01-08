class BudgetCategoryModel {
  final String id;
  final String name;
  final double allocated;
  final double spent;
  final String eventId;
  final DateTime createdAt;

  BudgetCategoryModel({
    required this.id,
    required this.name,
    required this.allocated,
    required this.spent,
    required this.eventId,
    required this.createdAt,
  });

  double get remaining => allocated - spent;
  double get percentageSpent => (spent / allocated) * 100;
 
  BudgetCategoryModel copyWith({
    String? id,
    String? name,
    double? allocated,
    double? spent,
    String? eventId,
    DateTime? createdAt,
  }) {
    return BudgetCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      allocated: allocated ?? this.allocated,
      spent: spent ?? this.spent,
      eventId: eventId ?? this.eventId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'allocated': allocated,
      'spent': spent,
      'eventId': eventId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BudgetCategoryModel.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryModel(
      id: json['id'],
      name: json['name'],
      allocated: json['allocated'],
      spent: json['spent'],
      eventId: json['eventId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
