import 'package:adv_basic/features/expenses/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final currencyFormatter = NumberFormat('#,###', 'vi_VN');

class TopExpenses extends StatelessWidget {
  final List<Expense> topExpenses;
  const TopExpenses({super.key, required this.topExpenses});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chi tiêu lớn nhất',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              if (topExpenses.isEmpty)
                Text(
                  'Chưa có khoản chi nào.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                ...topExpenses.map(
                  (e) => Text(
                    "${e.title}: ${currencyFormatter.format(e.amount * 1000)} VNĐ",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color.fromARGB(255, 38, 56, 64),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
