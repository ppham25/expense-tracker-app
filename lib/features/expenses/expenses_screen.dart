import 'package:adv_basic/features/expenses/models/expense.dart';
import 'package:adv_basic/features/expenses/services/expense_service.dart';
import 'package:adv_basic/features/expenses/widgets/chart/chart.dart';
import 'package:adv_basic/features/expenses/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:adv_basic/features/expenses/widgets/expenses_list/expenses_list.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _registeredExpenses = [];
  bool _isLoading = true;
  final ExpenseService _expenseService = ExpenseService();

  Future<void> _loadExpenses() async {
    try {
      final expenses = await _expenseService.getExpenses();
      setState(() {
        _registeredExpenses.clear();
        _registeredExpenses.addAll(expenses as Iterable<Expense>);
        _isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load expenses: $error')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(onAddExpense: _addExpense),
    );
  }

  Future<void> _addExpense({
    required String title,
    required double amount,
    required DateTime date,
    required Category category,
  }) async {
    try {
      final newExpense = await _expenseService.addExpense(
        title: title,
        amount: amount,
        date: date,
        category: category,
      );

      if (!mounted) return;
      setState(() {
        _registeredExpenses.insert(0, newExpense);
      });
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add expense: $error')));
    }
  }

  void _openEditExpenseOverlay(Expense expense) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder:
          (ctx) => NewExpense(
            expense: expense,
            onAddExpense: ({
              required String title,
              required double amount,
              required DateTime date,
              required Category category,
            }) async {
              await _updatedExpense(
                id: expense.id,
                title: title,
                amount: amount,
                date: date,
                category: category,
              );
            },
          ),
    );
  }

  Future<void> _updatedExpense({
    required String id,
    required String title,
    required double amount,
    required DateTime date,
    required Category category,
  }) async {
    final updateExpense = await _expenseService.updateExpense(
      id: id,
      title: title,
      amount: amount,
      date: date,
      category: category,
    );
    if (!mounted) return;
    setState(() {
      final index = _registeredExpenses.indexWhere(
        (expense) => expense.id == id,
      );
      if (index != -1) {
        _registeredExpenses[index] = updateExpense;
      }
    });
  }

  Future<void> _removeExpense(Expense expense) async {
    try {
      final removedIndex = _registeredExpenses.indexOf(expense);
      final removedExpense = expense;

      await _expenseService.deleteExpense(expense.id);
      if (!mounted) return;
      setState(() {
        _registeredExpenses.remove(expense);
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 3),
          content: Text('Expense deleted.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              try {
                final restoredExpense = await _expenseService.addExpense(
                  title: removedExpense.title,
                  amount: removedExpense.amount,
                  date: removedExpense.date,
                  category: removedExpense.category,
                );

                if (!mounted) return;
                setState(() {
                  _registeredExpenses.insert(removedIndex, restoredExpense);
                });
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to restore expense: $error')),
                );
              }
            },
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete expense: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    Widget mainContent = const Center(
      child: Text('No expenses found. Start adding some!'),
    );
    if (_isLoading) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registeredExpenses,
        onRemoveExpense: _removeExpense,
        onEditExpense: _openEditExpenseOverlay,
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(onPressed: _openAddExpenseOverlay, icon: Icon(Icons.add)),
        ],
      ),
      body:
          width < 600
              ? Column(
                children: [
                  Chart(expenses: _registeredExpenses),
                  Text("Expense List"),
                  Expanded(child: mainContent),
                ],
              )
              : Row(
                children: [
                  Expanded(child: Chart(expenses: _registeredExpenses)),
                  Expanded(
                    child: Column(
                      children: [
                        Text("Expense List"),
                        Expanded(child: mainContent),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
