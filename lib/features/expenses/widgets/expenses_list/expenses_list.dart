import 'package:adv_basic/features/expenses/models/expense.dart';
import 'package:adv_basic/features/expenses/widgets/expenses_list/expense_item.dart';
import 'package:flutter/material.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onRemoveExpense,
    required this.onEditExpense,
  });

  final void Function(Expense expense) onRemoveExpense;
  final void Function(Expense expense) onEditExpense;

  final List<Expense> expenses;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder:
          (ctx, index) => Dismissible(
            key: ValueKey(expenses[index]),
            background: Container(color: Theme.of(context).colorScheme.error),
            onDismissed: (direction) {
              onRemoveExpense(expenses[index]);
            },
            child: ExpenseItem(
              expense: expenses[index],
              onEditExpense: onEditExpense,
            ),
          ),
    );
  }
}
