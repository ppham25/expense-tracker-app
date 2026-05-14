import 'package:adv_basic/features/budget/models/budget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

final currencyFormatter = NumberFormat('#,###', 'vi_VN');

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.eachBudget,
    required this.onSetBudget,
    required this.updateBudget,
  });

  final Budget eachBudget;
  final void Function(Budget budget) onSetBudget;
  final void Function(Budget budget) updateBudget;

  @override
  Widget build(BuildContext context) {
    Widget __buildNoBudgetCard(Budget budget) {
      return Card(
        color: Theme.of(context).cardColor,
        margin: CardTheme.of(context).margin,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${budget.category.toUpperCase()} - CHƯA CÓ BUDGET",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: const Color.fromARGB(255, 38, 59, 96),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "Bạn đã tiêu ${currencyFormatter.format(budget.spent * 1000)} VND trong tháng ${budget.month}/${budget.year} tới thời điểm hiện tại đó nhá ^u^",
              ),
              SizedBox(height: 8),
              Text(
                "${budget.funMessage}",
                style: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 34, 59, 105),
                ),
              ),
              TextButton(
                onPressed: () => onSetBudget(budget),
                child: Text("Đặt budget nè"),
              ),
            ],
          ),
        ),
      );
    }

    Widget __buildBudgetCard(Budget budget) {
      return Card(
        color: Theme.of(context).cardColor,
        margin: CardTheme.of(context).margin,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "${budget.category.toUpperCase()} - ${budget.percentageUsed ?? 0}%",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: const Color.fromARGB(255, 38, 59, 96),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () => updateBudget(budget),
                      icon: Icon(Icons.edit),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: budget.progressValue,
                color: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.3),
              ),
              SizedBox(height: 8),
              Text(
                "Budget: ${currencyFormatter.format(budget.limitAmount! * 1000)} VND",
              ),
              Text(
                "Đã tiêu: ${currencyFormatter.format(budget.spent * 1000)} VND",
              ),
              Text(
                "Còn lại: ${currencyFormatter.format(budget.remaining! * 1000)} VND",
              ),
              SizedBox(height: 8),
              Text("${budget.funMessage}"),
            ],
          ),
        ),
      );
    }

    if (eachBudget.hasBudget) {
      return __buildBudgetCard(eachBudget);
    } else {
      return __buildNoBudgetCard(eachBudget);
    }
  }
}
