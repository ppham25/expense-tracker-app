import 'package:adv_basic/features/budget/models/budget.dart';
import 'package:adv_basic/features/expenses/models/expense.dart';
import 'package:flutter/material.dart';
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

  String _formatMoney(double value) {
    return '${currencyFormatter.format(value * 1000)} VNĐ';
  }

  String _statusLabel(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.safe:
        return 'An toàn';
      case BudgetStatus.watch:
        return 'Cần chú ý';
      case BudgetStatus.warning:
        return 'Cảnh báo';
      case BudgetStatus.over:
        return 'Vượt ngân sách';
      case BudgetStatus.noBudget:
        return 'Chưa thiết lập';
    }
  }

  IconData _statusIcon(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.safe:
        return Icons.check_circle_outline;
      case BudgetStatus.watch:
        return Icons.notifications_active_outlined;
      case BudgetStatus.warning:
        return Icons.warning_amber_rounded;
      case BudgetStatus.over:
        return Icons.error_outline;
      case BudgetStatus.noBudget:
        return Icons.add_circle_outline;
    }
  }

  Color _statusColor(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.safe:
        return const Color(0xFF2E7D32);
      case BudgetStatus.watch:
        return const Color(0xFF1565C0);
      case BudgetStatus.warning:
        return const Color(0xFFEF6C00);
      case BudgetStatus.over:
        return const Color(0xFFC62828);
      case BudgetStatus.noBudget:
        return const Color(0xFF455A64);
    }
  }

  Color _statusBackground(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.safe:
        return const Color(0xFFE8F5E9);
      case BudgetStatus.watch:
        return const Color(0xFFE3F2FD);
      case BudgetStatus.warning:
        return const Color(0xFFFFF3E0);
      case BudgetStatus.over:
        return const Color(0xFFFFEBEE);
      case BudgetStatus.noBudget:
        return const Color(0xFFECEFF1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (eachBudget.hasBudget) {
      return _buildBudgetCard(context, eachBudget);
    }

    return _buildNoBudgetCard(context, eachBudget);
  }

  Widget _buildNoBudgetCard(BuildContext context, Budget budget) {
    final color = _statusColor(budget.status);
    final background = _statusBackground(budget.status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(_statusIcon(budget.status), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatCategoryName(budget.category),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _statusLabel(budget.status),
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Đã chi ${_formatMoney(budget.spent)} trong tháng ${budget.month}/${budget.year}.',
                      style: const TextStyle(height: 1.35),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      budget.funMessage,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF455A64),
                        height: 1.35,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () => onSetBudget(budget),
                        icon: const Icon(Icons.add),
                        label: const Text('Đặt ngân sách'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, Budget budget) {
    final color = _statusColor(budget.status);
    final background = _statusBackground(budget.status);
    final percent = budget.percentageUsed ?? 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.22)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: background,
                    child: Icon(_statusIcon(budget.status), color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formatCategoryName(budget.category),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _statusLabel(budget.status),
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => updateBudget(budget),
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Cập nhật ngân sách',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$percent%',
                    style: TextStyle(
                      color: color,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text('đã sử dụng'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: budget.progressValue,
                  color: color,
                  backgroundColor: color.withOpacity(0.15),
                ),
              ),
              const SizedBox(height: 14),
              _MoneyRow(
                label: 'Ngân sách',
                value: _formatMoney(budget.limitAmount ?? 0),
              ),
              _MoneyRow(label: 'Đã chi', value: _formatMoney(budget.spent)),
              _MoneyRow(
                label: 'Còn lại',
                value: _formatMoney(budget.remaining ?? 0),
                valueColor: color,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  budget.funMessage,
                  style: const TextStyle(
                    height: 1.35,
                    fontStyle: FontStyle.italic,
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

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF607D8B)),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w700, color: valueColor),
          ),
        ],
      ),
    );
  }
}
