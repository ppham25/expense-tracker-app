import 'package:adv_basic/features/statistics/models/spending_trend.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpendingTrendCard extends StatelessWidget {
  const SpendingTrendCard({super.key, required this.trend});

  final SpendingTrend trend;

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');
    return formatter.format(value);
  }

  IconData get _trendIcon {
    if (trend.trendStatus == 'increase') {
      return Icons.trending_up;
    }

    if (trend.trendStatus == 'decrease') {
      return Icons.trending_down;
    }

    return Icons.trending_flat;
  }

  String get _changeText {
    if (trend.previousMonth == null) {
      return 'Chưa có dữ liệu tháng trước';
    }

    final sign = trend.changeAmount > 0 ? '+' : '';
    return '$sign${_formatCurrency(trend.changeAmount)} (${trend.changePercentage}%)';
  }

  @override
  Widget build(BuildContext context) {
    final previousMonth = trend.previousMonth;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xu hướng chi tiêu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(_trendIcon, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    trend.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Tháng ${trend.currentMonth.month}/${trend.currentMonth.year}: '
              '${_formatCurrency(trend.currentMonth.totalSpent)}',
            ),
            if (previousMonth != null)
              Text(
                'Tháng ${previousMonth.month}/${previousMonth.year}: '
                '${_formatCurrency(previousMonth.totalSpent)}',
              ),
            const SizedBox(height: 8),
            Text('Mức thay đổi: $_changeText'),
          ],
        ),
      ),
    );
  }
}
