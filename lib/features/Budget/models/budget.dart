enum BudgetStatus { noBudget, safe, watch, warning, over }

BudgetStatus budgetStatusFromString(String value) {
  switch (value) {
    case 'safe':
      return BudgetStatus.safe;
    case 'watch':
      return BudgetStatus.watch;
    case 'warning':
      return BudgetStatus.warning;
    case 'over':
      return BudgetStatus.over;
    case 'noBudget':
    case 'no_budget':
    default:
      return BudgetStatus.noBudget;
  }
}

class Budget {
  Budget({
    this.id,
    required this.categoryId,
    required this.category,
    required this.hasBudget,
    this.limitAmount,
    required this.spent,
    this.remaining,
    this.percentageUsed,
    required this.status,
    required this.month,
    required this.year,
    this.budgetMessage,
  });

  final int? id;
  final int categoryId;
  final String category;
  final bool hasBudget;
  final double? limitAmount;
  final double spent;
  final double? remaining;
  final int? percentageUsed;
  final BudgetStatus status;
  final int month;
  final int year;
  final String? budgetMessage;

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      categoryId: int.parse(
        (json['categoryId'] ?? json['category_id'] ?? 0).toString(),
      ),
      category: json['category'],
      hasBudget: json['hasBudget'] ?? false,
      limitAmount:
          json['limitAmount'] != null
              ? double.tryParse(json['limitAmount'].toString())
              : null,
      spent: double.tryParse(json['spent'].toString()) ?? 0.0,
      remaining:
          json['remaining'] != null
              ? double.tryParse(json['remaining'].toString())
              : null,
      percentageUsed:
          json['percentageUsed'] != null
              ? int.tryParse(json['percentageUsed'].toString())
              : null,
      status: budgetStatusFromString(json['status'].toString()),
      month: int.parse(json['month'].toString()),
      year: int.parse(json['year'].toString()),
      budgetMessage: json['budgetMessage']?.toString(),
    );
  }

  double get progressValue {
    if (percentageUsed == null) {
      return 0;
    }

    final progress = percentageUsed! / 100;
    return progress > 1 ? 1 : progress;
  }

  bool get isNoBudget => status == BudgetStatus.noBudget;

  String get funMessage {
    return budgetMessage ?? 'Chưa có thông điệp phù hợp.';
  }
}
