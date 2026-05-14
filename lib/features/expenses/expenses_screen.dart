// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, control_flow_in_finally

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
  final ExpenseService _expenseService = ExpenseService();

  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  int? _selectedMonth;
  int? _selectedYear;

  List<Expense> get _filteredExpenses {
    final searchText = _searchController.text.trim().toLowerCase();

    return _registeredExpenses.where((expense) {
      final matchesTitle =
          searchText.isEmpty ||
          expense.title.toLowerCase().contains(searchText);

      final matchesMonth =
          _selectedMonth == null || expense.date.month == _selectedMonth;

      final matchesYear =
          _selectedYear == null || expense.date.year == _selectedYear;

      return matchesTitle && matchesMonth && matchesYear;
    }).toList();
  }

  List<int> get _availableYears {
    final years =
        _registeredExpenses.map((expense) => expense.date.year).toSet();

    if (_selectedYear != null) {
      years.add(_selectedYear!);
    }

    final sortedYears = years.toList();
    sortedYears.sort((a, b) => b.compareTo(a));

    return sortedYears;
  }

  Future<void> _loadExpenses() async {
    try {
      final expenses = await _expenseService.getExpenses();

      if (!mounted) return;
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          duration: const Duration(seconds: 3),
          content: const Text('Expense deleted.'),
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

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedMonth = null;
      _selectedYear = null;
    });
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Tìm kiếm theo tên chi tiêu',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                      : null,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _selectedMonth,
                  decoration: const InputDecoration(
                    labelText: 'Tháng',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Tất cả tháng'),
                    ),
                    ...List.generate(
                      12,
                      (index) => DropdownMenuItem<int?>(
                        value: index + 1,
                        child: Text('Tháng ${index + 1}'),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Năm',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Tất cả năm'),
                    ),
                    ..._availableYears.map(
                      (year) => DropdownMenuItem<int?>(
                        value: year,
                        child: Text(year.toString()),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value;
                    });
                  },
                ),
              ),
              IconButton(
                tooltip: 'Xóa bộ lọc',
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final filteredExpenses = _filteredExpenses;

    Widget mainContent = const Center(
      child: Text('No matching expenses found.'),
    );

    if (_isLoading) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (filteredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: filteredExpenses,
        onRemoveExpense: _removeExpense,
        onEditExpense: _openEditExpenseOverlay,
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body:
          width < 600
              ? Column(
                children: [
                  Chart(expenses: filteredExpenses),
                  _buildFilterSection(),
                  const Text("Expense List"),
                  Expanded(child: mainContent),
                ],
              )
              : Row(
                children: [
                  Expanded(child: Chart(expenses: filteredExpenses)),
                  Expanded(
                    child: Column(
                      children: [
                        _buildFilterSection(),
                        const Text("Expense List"),
                        Expanded(child: mainContent),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
