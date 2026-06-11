// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, control_flow_in_finally

import 'package:adv_basic/features/expenses/models/expense.dart';
import 'package:adv_basic/features/expenses/services/expense_service.dart';
import 'package:adv_basic/features/expenses/widgets/chart/chart.dart';
import 'package:adv_basic/features/expenses/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:adv_basic/features/expenses/widgets/expenses_list/expenses_list.dart';
import 'package:adv_basic/features/budget/models/budget.dart';
import 'package:adv_basic/features/budget/services/budget_service.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key, this.onGoToBudget});

  final VoidCallback? onGoToBudget;

  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _registeredExpenses = [];
  final ExpenseService _expenseService = ExpenseService();
  final BudgetService _budgetService = BudgetService();
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

  String _budgetStatusLabel(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.watch:
        return 'Cần chú ý';
      case BudgetStatus.warning:
        return 'Cảnh báo';
      case BudgetStatus.over:
        return 'Vượt ngân sách';
      case BudgetStatus.safe:
        return 'An toàn';
      case BudgetStatus.noBudget:
        return 'Chưa thiết lập';
    }
  }

  Color _budgetStatusColor(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.watch:
        return const Color(0xFF1565C0);
      case BudgetStatus.warning:
        return const Color(0xFFEF6C00);
      case BudgetStatus.over:
        return const Color(0xFFC62828);
      case BudgetStatus.safe:
        return const Color(0xFF2E7D32);
      case BudgetStatus.noBudget:
        return const Color(0xFF455A64);
    }
  }

  IconData _budgetStatusIcon(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.watch:
        return Icons.notifications_active_outlined;
      case BudgetStatus.warning:
        return Icons.warning_amber_rounded;
      case BudgetStatus.over:
        return Icons.error_outline;
      case BudgetStatus.safe:
        return Icons.check_circle_outline;
      case BudgetStatus.noBudget:
        return Icons.add_circle_outline;
    }
  }

  Future<void> _showBudgetReminderAfterAddingExpense(Expense expense) async {
    try {
      final budgets = await _budgetService.getBudgets(
        month: expense.date.month,
        year: expense.date.year,
      );

      Budget? matchedBudget;

      for (final budget in budgets) {
        if (budget.categoryId == expense.categoryId) {
          matchedBudget = budget;
          break;
        }
      }

      if (!mounted) return;

      if (matchedBudget == null ||
          matchedBudget.status == BudgetStatus.noBudget ||
          !matchedBudget.hasBudget) {
        _showNoBudgetSnackBar(expense);
        return;
      }

      _showBudgetStatusSnackBar(matchedBudget);
    } catch (error) {
      debugPrint('Không thể kiểm tra nhắc nhở ngân sách: $error');
    }
  }

  void _showBudgetStatusSnackBar(Budget budget) {
    final statusColor = _budgetStatusColor(budget.status);
    final statusLabel = _budgetStatusLabel(budget.status);
    final statusIcon = _budgetStatusIcon(budget.status);

    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: statusColor,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(statusIcon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nhắc nhở ngân sách: $statusLabel',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    budget.funMessage,
                    style: const TextStyle(color: Colors.white, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
        action:
            widget.onGoToBudget == null
                ? null
                : SnackBarAction(
                  label: 'Xem',
                  textColor: Colors.lightBlueAccent,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    widget.onGoToBudget!();
                  },
                ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      snackBarController.close();
    });
  }

  void _showNoBudgetSnackBar(Expense expense) {
    final categoryName = formatCategoryName(expense.category);

    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF455A64),
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.add_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Danh mục "$categoryName" chưa có ngân sách tháng '
                '${expense.date.month}/${expense.date.year}.',
                style: const TextStyle(color: Colors.white, height: 1.3),
              ),
            ),
          ],
        ),
        action:
            widget.onGoToBudget == null
                ? null
                : SnackBarAction(
                  label: 'Tạo',
                  textColor: Colors.lightBlueAccent,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    widget.onGoToBudget!();
                  },
                ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      snackBarController.close();
    });
  }

  Future<void> _addExpense({
    required String title,
    required double amount,
    required DateTime date,
    required int categoryId,
  }) async {
    try {
      final newExpense = await _expenseService.addExpense(
        title: title,
        amount: amount,
        date: date,
        categoryId: categoryId,
      );

      if (!mounted) return;

      setState(() {
        _registeredExpenses.insert(0, newExpense);
      });

      ScaffoldMessenger.of(context).clearSnackBars();

      await _showBudgetReminderAfterAddingExpense(newExpense);
    } catch (error) {
      if (!mounted) return;

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
              required int categoryId,
            }) async {
              await _updatedExpense(
                id: expense.id,
                title: title,
                amount: amount,
                date: date,
                categoryId: categoryId,
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
    required int categoryId,
  }) async {
    final updateExpense = await _expenseService.updateExpense(
      id: id,
      title: title,
      amount: amount,
      date: date,
      categoryId: categoryId,
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

      final snackBarController = ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: const Text('Expense deleted.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              try {
                final restoredExpense = await _expenseService.addExpense(
                  title: removedExpense.title,
                  amount: removedExpense.amount,
                  date: removedExpense.date,
                  categoryId: removedExpense.categoryId,
                );

                if (!mounted) return;

                setState(() {
                  _registeredExpenses.insert(removedIndex, restoredExpense);
                });

                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              } catch (error) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to restore expense: $error')),
                );
              }
            },
          ),
        ),
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        snackBarController.close();
      });
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
                  initialValue: _selectedMonth,
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
                  initialValue: _selectedYear,
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
