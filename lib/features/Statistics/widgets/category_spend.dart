import 'package:adv_basic/features/expenses/models/expense.dart';
import 'package:adv_basic/features/statistics/models/statistics_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final currencyFormatter = NumberFormat('#,###', 'vi_VN');

class CategorySpend extends StatelessWidget {
  final List<CategoryBreakdownItem> categoryBreakdown;

  const CategorySpend({super.key, required this.categoryBreakdown});

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
                'Chi tiêu theo danh mục',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (categoryBreakdown.isEmpty)
                Text(
                  'Chưa có khoản chi nào.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                ...categoryBreakdown.map(
                  (item) => Text(
                    '${formatCategoryName(item.category)}: ${currencyFormatter.format(item.amount * 1000)} VNĐ',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w500,
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
