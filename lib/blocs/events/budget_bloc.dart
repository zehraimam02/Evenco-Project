import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:evenco_app/models/expense_model.dart';
import 'package:evenco_app/models/budget_category_model.dart';
import 'package:evenco_app/services/database_service.dart';

// Events
abstract class BudgetEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBudgetCategories extends BudgetEvent {
  final String eventId;
  LoadBudgetCategories(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class AddBudgetCategory extends BudgetEvent {
  final String eventId;
  final String name;
  final double allocated;
  AddBudgetCategory(this.eventId, this.name, this.allocated);

  @override
  List<Object?> get props => [eventId, name, allocated];
}

class UpdateBudgetCategory extends BudgetEvent {
  final BudgetCategoryModel category;
  UpdateBudgetCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteBudgetCategory extends BudgetEvent {
  final String categoryId;
  DeleteBudgetCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class AddExpense extends BudgetEvent {
  final String categoryId;
  final String description;
  final double amount;
  AddExpense(this.categoryId, this.description, this.amount);

  @override
  List<Object?> get props => [categoryId, description, amount];
}

// States
abstract class BudgetState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final List<BudgetCategoryModel> categories;
  final Map<String, List<ExpenseModel>> expenses;
  
  BudgetLoaded(this.categories, this.expenses);

  @override
  List<Object?> get props => [categories, expenses];
}

class BudgetError extends BudgetState {
  final String message;
  BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final DatabaseService _databaseService;

  BudgetBloc(this._databaseService) : super(BudgetInitial()) {
    on<LoadBudgetCategories>(_onLoadBudgetCategories);
    on<AddBudgetCategory>(_onAddBudgetCategory);
    on<UpdateBudgetCategory>(_onUpdateBudgetCategory);
    on<DeleteBudgetCategory>(_onDeleteBudgetCategory);
    on<AddExpense>(_onAddExpense);
  }

  Future<void> _onLoadBudgetCategories(
    LoadBudgetCategories event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final categories = await _databaseService.getBudgetCategories(event.eventId);
      final expenses = await _databaseService.getAllExpenses(event.eventId);
      emit(BudgetLoaded(categories, expenses));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onAddBudgetCategory(
    AddBudgetCategory event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      final category = BudgetCategoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.name,
        allocated: event.allocated,
        spent: 0,
        eventId: event.eventId,
        createdAt: DateTime.now(),
      );
      await _databaseService.addBudgetCategory(category);
      add(LoadBudgetCategories(event.eventId));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onUpdateBudgetCategory(
    UpdateBudgetCategory event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await _databaseService.updateBudgetCategory(event.category);
      add(LoadBudgetCategories(event.category.eventId));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onDeleteBudgetCategory(
    DeleteBudgetCategory event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await _databaseService.deleteBudgetCategory(event.categoryId);
      if (state is BudgetLoaded) {
        final currentState = state as BudgetLoaded;
        add(LoadBudgetCategories(
          currentState.categories.first.eventId,
        ));
      }
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      // Create and add the new expense
      final expense = ExpenseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: event.categoryId,
        description: event.description,
        amount: event.amount,
        date: DateTime.now(),
      );
      await _databaseService.addExpense(expense);

      // Get the current category and update its spent amount
      if (state is BudgetLoaded) {
        final currentState = state as BudgetLoaded;
        final category = currentState.categories.firstWhere(
          (cat) => cat.id == event.categoryId,
        );
        
        // Create updated category with new spent amount
        final updatedCategory = category.copyWith(
          spent: category.spent + event.amount,
        );
        
        // Update the category in database
        await _databaseService.updateBudgetCategory(updatedCategory);
        
        // Reload the budget categories to refresh the UI
        add(LoadBudgetCategories(
          currentState.categories.first.eventId,
        ));
      }
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

}
