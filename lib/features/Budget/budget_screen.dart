import 'package:adv_basic/features/budget/models/budget.dart';
import 'package:adv_basic/features/budget/services/budget_service.dart';
import 'package:adv_basic/features/budget/widgets/budget_card.dart';
import 'package:adv_basic/features/budget/widgets/new_budget.dart';
import 'package:adv_basic/features/budget/widgets/pick_date.dart';
import 'package:flutter/material.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final BudgetService _budgetService = BudgetService();

  late int _selectedMonth;
  late int _selectedYear;

  bool _isLoading = true;
  List<Budget> _budgets = [];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;

    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final budgetData = await _budgetService.getBudgets(
        month: _selectedMonth,
        year: _selectedYear,
      );

      if (!mounted) return;

      setState(() {
        _budgets = budgetData;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load budgets: $error')));
    }
  }

  void _openSetBudgetSheet(Budget budget) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder:
          (ctx) => NewBudget(
            budget: budget,
            onSave: (limitAmount) async {
              await _addBudget(
                category: budget.category,
                limitAmount: limitAmount,
              );
            },
          ),
    );
  }

  Future<void> _addBudget({
    required String category,
    required double limitAmount,
  }) async {
    try {
      await _budgetService.addBudget(
        category: category,
        limitAmount: limitAmount,
        month: _selectedMonth,
        year: _selectedYear,
      );
      if (!mounted) return;

      _loadBudgets();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add budget: $error')));
    }
  }

  Future<void> onRemoveBudget(Budget budget) async {
    try {
      await _budgetService.deleteBudget(budget.id!);
      if (!mounted) return;

      setState(() {
        _loadBudgets();
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete budget: $error')),
      );
    }
  }

  void openUpdateBudgetSheet(Budget budget) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder:
          (ctx) => NewBudget(
            budget: budget,
            onSave: (limitAmount) async {
              await _updateBudget(id: budget.id!, limitAmount: limitAmount);
            },
          ),
    );
  }

  Future<void> _updateBudget({
    required int id,
    required double limitAmount,
  }) async {
    try {
      await _budgetService.updateBudget(id: id, limitAmount: limitAmount);
      if (!mounted) return;

      _loadBudgets();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update budget: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else {
      content = Column(
        children: [
          PickDate(
            selectedMonth: _selectedMonth,
            selectedYear: _selectedYear,
            onDateChanged: (month, year) {
              setState(() {
                _selectedMonth = month;
                _selectedYear = year;
              });
              _loadBudgets();
            },
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _budgets.length,
              itemBuilder: (context, index) {
                final budget = _budgets[index];
                if (budget.hasBudget) {
                  return Dismissible(
                    key: ValueKey(budget),
                    background: Container(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onDismissed: (direction) {
                      onRemoveBudget(budget);
                    },
                    child: BudgetCard(
                      eachBudget: budget,
                      onSetBudget: (b) {
                        _openSetBudgetSheet(b);
                      },
                      updateBudget: (b) {
                        openUpdateBudgetSheet(b);
                      },
                    ),
                  );
                } else {
                  return BudgetCard(
                    eachBudget: budget,
                    onSetBudget: (b) {
                      _openSetBudgetSheet(b);
                    },
                    updateBudget: (b) {
                      openUpdateBudgetSheet(b);
                    },
                  );
                }
              },
            ),
          ),
        ],
      );
    }

    return Scaffold(appBar: AppBar(title: const Text('Budget')), body: content);
  }
}
