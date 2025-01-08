class ExpenseModel {
  final String id;
  final String categoryId;
  final String description;
  final double amount;
  final DateTime date;

  ExpenseModel({
    required this.id,
    required this.categoryId,
    required this.description,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      categoryId: json['categoryId'],
      description: json['description'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
    );
  }
}