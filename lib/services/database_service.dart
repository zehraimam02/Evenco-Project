import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/budget_category_model.dart';
import '../models/expense_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<BudgetCategoryModel>> getBudgetCategories(String eventId) async {
    final snapshot = await _firestore
        .collection('budget_categories')
        .where('eventId', isEqualTo: eventId)
        .get();
    
    return snapshot.docs
        .map((doc) => BudgetCategoryModel.fromJson(doc.data()))
        .toList();
  }

  Future<Map<String, List<ExpenseModel>>> getAllExpenses(String eventId) async {
    final categories = await getBudgetCategories(eventId);
    final Map<String, List<ExpenseModel>> expenses = {};
    
    for (var category in categories) {
      final snapshot = await _firestore
          .collection('expenses')
          .where('categoryId', isEqualTo: category.id)
          .get();
      
      expenses[category.id] = snapshot.docs
          .map((doc) => ExpenseModel.fromJson(doc.data()))
          .toList();
    }
    
    return expenses;
  }

  Future<void> addBudgetCategory(BudgetCategoryModel category) async {
    await _firestore
        .collection('budget_categories')
        .doc(category.id)
        .set(category.toJson());
  }

  Future<void> updateBudgetCategory(BudgetCategoryModel category) async {
    await _firestore
        .collection('budget_categories')
        .doc(category.id)
        .update(category.toJson());
  }

  Future<void> deleteBudgetCategory(String categoryId) async {
    await _firestore.collection('budget_categories').doc(categoryId).delete();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _firestore
        .collection('expenses')
        .doc(expense.id)
        .set(expense.toJson());
  }
}
