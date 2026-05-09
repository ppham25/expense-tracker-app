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
    case 'no_budget':
    default:
      return BudgetStatus.noBudget;
  }
}

class Budget {
  Budget({
    this.id,
    required this.category,
    required this.hasBudget,
    this.limitAmount,
    required this.spent,
    this.remaining,
    this.percentageUsed,
    required this.status,
    required this.month,
    required this.year,
  });

  final int? id;
  final String category;
  final bool hasBudget;
  final double? limitAmount;
  final double spent;
  final double? remaining;
  final int? percentageUsed;
  final BudgetStatus status;
  final int month;
  final int year;

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      category: json['category'],
      hasBudget: json['hasBudget'] ?? false,
      limitAmount:
          json['limitAmount']
              ? double.tryParse(json['limitAmount'].toString())
              : null,
      spent: double.tryParse(json['spent'].toString()) ?? 0.0,
      remaining:
          json['remaining']
              ? double.tryParse(json['remaining'].toString())
              : null,
      percentageUsed:
          json['percentageUsed']
              ? int.tryParse(json['percentageUsed'].toString())
              : null,
      status: budgetStatusFromString(json['status']),
      month: json['month'],
      year: json['year'],
    );
  }
  double? get progressValue {
    if (percentageUsed == null) {
      return null;
    }
    final progress = percentageUsed! / 100;

    return progress > 1 ? 1 : progress;
  }

  bool get isNoBudget => status == BudgetStatus.noBudget;
}
