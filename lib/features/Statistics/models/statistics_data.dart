import 'package:adv_basic/features/expenses/models/expense.dart';

class StatisticsData {
  StatisticsData({
    required this.month,
    required this.year,
    required this.monthlySummary,
    required this.dailySpending,
    required this.categoryBreakdown,
    required this.topExpenses,
  });

  final int month;
  final int year;
  final MonthlySummary monthlySummary;
  final List<DailySpendingItem> dailySpending;
  final List<CategoryBreakdownItem> categoryBreakdown;
  final List<Expense> topExpenses;

  factory StatisticsData.fromJson(Map<String, dynamic> json) {
    return StatisticsData(
      month: json['month'],
      year: json['year'],
      monthlySummary: MonthlySummary.fromJson(json['monthlySummary']),
      dailySpending:
          (json['dailySpending'] as List)
              .map((item) => DailySpendingItem.fromJson(item))
              .toList(),
      categoryBreakdown:
          (json['categoryBreakdown'] as List)
              .map((item) => CategoryBreakdownItem.fromJson(item))
              .toList(),
      topExpenses:
          (json['topExpenses'] as List)
              .map((item) => Expense.fromJson(item))
              .toList(),
    );
  }
}

class MonthlySummary {
  MonthlySummary({required this.totalSpent, required this.expenseCount});

  final double totalSpent;
  final int expenseCount;

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    return MonthlySummary(
      totalSpent: double.parse(json['totalSpent'].toString()),
      expenseCount: json['expenseCount'],
    );
  }
}

class DailySpendingItem {
  DailySpendingItem({required this.day, required this.amount});

  final int day;
  final double amount;

  factory DailySpendingItem.fromJson(Map<String, dynamic> json) {
    return DailySpendingItem(
      day: json['day'],
      amount: double.parse(json['amount'].toString()),
    );
  }
}

class CategoryBreakdownItem {
  CategoryBreakdownItem({
    required this.categoryId,
    required this.category,
    required this.amount,
    required this.percentage,
  });

  final int categoryId;
  final String category;
  final double amount;
  final double percentage;

  factory CategoryBreakdownItem.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownItem(
      categoryId: int.parse(
        (json['categoryId'] ?? json['category_id'] ?? 0).toString(),
      ),
      category: json['category'].toString(),
      amount: double.parse(json['amount'].toString()),
      percentage: double.parse(json['percentage'].toString()),
    );
  }
}
