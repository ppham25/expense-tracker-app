import 'package:flutter/material.dart';

import 'package:adv_basic/features/expenses/widgets/chart/chart_bar.dart';
import 'package:adv_basic/features/expenses/models/expense.dart';

class Chart extends StatelessWidget {
  const Chart({super.key, required this.expenses});

  final List<Expense> expenses;

  List<ExpenseBucket> get buckets {
    final categoryNames = expenses.map((expense) => expense.category).toSet();

    if (categoryNames.isEmpty) {
      return const [];
    }

    return categoryNames
        .map((category) => ExpenseBucket.forCategory(expenses, category))
        .toList();
  }

  double get maxTotalExpense {
    double maxTotalExpense = 0;

    for (final bucket in buckets) {
      if (bucket.totalExpenses > maxTotalExpense) {
        maxTotalExpense = bucket.totalExpenses;
      }
    }

    return maxTotalExpense;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    if (buckets.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        height: 180,
        alignment: Alignment.center,
        child: const Text('Chưa có dữ liệu biểu đồ'),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            // ignore: deprecated_member_use
            Theme.of(context).colorScheme.primary.withOpacity(0.3),
            // ignore: deprecated_member_use
            Theme.of(context).colorScheme.primary.withOpacity(0.0),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final bucket in buckets)
                  ChartBar(
                    fill:
                        bucket.totalExpenses == 0
                            ? 0
                            : bucket.totalExpenses / maxTotalExpense,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children:
                buckets
                    .map(
                      (bucket) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            categoryIcons[bucket.category.toLowerCase()] ??
                                Icons.category,
                            color:
                                isDarkMode
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(
                                      context,
                                      // ignore: deprecated_member_use
                                    ).colorScheme.primary.withOpacity(0.7),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}
