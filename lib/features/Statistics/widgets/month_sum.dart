import 'package:adv_basic/features/statistics/models/statistics_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final currencyFormatter = NumberFormat('#,###', 'vi_VN');

class MonthlySum extends StatelessWidget {
  final MonthlySummary sumData;
  const MonthlySum({super.key, required this.sumData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Tổng chi tháng',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${currencyFormatter.format(sumData.totalSpent * 1000)} VNĐ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Số lần chi tiêu',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${sumData.expenseCount}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
