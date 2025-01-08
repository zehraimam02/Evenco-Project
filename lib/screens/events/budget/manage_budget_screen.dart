import 'package:evenco_app/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../blocs/events/budget_bloc.dart';
import '../../../models/budget_category_model.dart';
import '../../../models/expense_model.dart';

class ManageBudgetScreen extends StatefulWidget {
  final EventModel event;

  const ManageBudgetScreen({
    super.key,
    required this.event,
  });

  @override
  State<ManageBudgetScreen> createState() => _ManageBudgetScreenState();
}

class _ManageBudgetScreenState extends State<ManageBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<BudgetBloc>().add(LoadBudgetCategories(widget.event.id));
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BudgetLoaded) {
            return _buildContent(context, state);
          }
          if (state is BudgetError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No budget data available'));
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, BudgetLoaded state) {
    final totalSpent = state.categories.fold<double>(
      0,
      (sum, category) => sum + category.spent,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBudgetOverview(totalSpent),
          const Divider(height: 1),
          _buildCategoryList(state),
        ],
      ),
    );
  }

  Widget _buildBudgetOverview(double totalSpent) {
    final percentageSpent = widget.event.budget > 0 
        ? (totalSpent / widget.event.budget * 100).clamp(0, 100)
        : 0.0;
    final remaining = widget.event.budget - totalSpent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Total Budget',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(symbol: '\$').format(widget.event.budget),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentageSpent / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentageSpent > 90 ? Colors.red : Colors.blue,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBudgetStat(
                'Spent',
                NumberFormat.currency(symbol: '\$').format(totalSpent),
                Colors.orange,
              ),
              _buildBudgetStat(
                'Remaining',
                NumberFormat.currency(symbol: '\$').format(remaining),
                remaining >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(BudgetLoaded state) {
    if (state.categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.category_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No budget categories yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _showAddCategoryDialog(context),
                child: const Text('Add Category'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: state.categories.length,
      itemBuilder: (context, index) {
        final category = state.categories[index];
        final expenses = state.expenses[category.id] ?? [];
        return _buildCategoryCard(category, expenses);
      },
    );
  }

  Widget _buildCategoryCard(BudgetCategoryModel category, List<ExpenseModel> expenses) {
    final percentageSpent = (category.spent / category.allocated * 100).clamp(0, 100);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleCategoryAction(value, category),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'addExpense',
                      child: Text('Add Expense'),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit Category'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Category'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Allocated: ${NumberFormat.currency(symbol: '\$').format(category.allocated)}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  'Spent: ${NumberFormat.currency(symbol: '\$').format(category.spent)}',
                  style: TextStyle(
                    color: percentageSpent > 90 ? Colors.red : Colors.grey.shade600,
                    fontWeight: percentageSpent > 90 ? FontWeight.bold : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentageSpent / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentageSpent > 90 ? Colors.red : Colors.blue,
                ),
                minHeight: 6,
              ),
            ),
            if (expenses.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Recent Expenses',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildExpensesList(expenses),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesList(List<ExpenseModel> expenses) {
    return Column(
      children: expenses
          .take(3)
          .map((expense) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        expense.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      NumberFormat.currency(symbol: '\$').format(expense.amount),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  void _handleCategoryAction(String action, BudgetCategoryModel category) {
    switch (action) {
      case 'addExpense':
        _showAddExpenseDialog(category);
        break;
      case 'edit':
        _showEditCategoryDialog(category);
        break;
      case 'delete':
        _showDeleteCategoryDialog(category);
        break;
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
    _categoryController.clear();
    _amountController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Budget Category'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g., Catering, Decoration',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Allocated Amount',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<BudgetBloc>().add(
                        AddBudgetCategory(
                          widget.event.id,
                          _categoryController.text,
                          double.parse(_amountController.text),
                        ),
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAddExpenseDialog(BudgetCategoryModel category) {
    _amountController.clear();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Expense to ${category.name}'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter expense description',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<BudgetBloc>().add(
                        AddExpense(
                          category.id,
                          descriptionController.text,
                          double.parse(_amountController.text),
                        ),
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(BudgetCategoryModel category) {
    _categoryController.text = category.name;
    _amountController.text = category.allocated.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Budget Category'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g., Catering, Decoration',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Allocated Amount',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final updatedCategory = category.copyWith(
                    name: _categoryController.text,
                    allocated: double.parse(_amountController.text),
                  );
                  context.read<BudgetBloc>().add(
                    UpdateBudgetCategory(updatedCategory),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCategoryDialog(BudgetCategoryModel category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text(
            'Are you sure you want to delete "${category.name}"? This will also delete all expenses in this category and cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                context.read<BudgetBloc>().add(DeleteBudgetCategory(category.id));
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

}