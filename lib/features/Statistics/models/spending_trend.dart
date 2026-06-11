class SpendingTrend {
  SpendingTrend({
    required this.selectedMonth,
    required this.selectedYear,
    required this.previousMonth,
    required this.currentMonth,
    required this.changeAmount,
    required this.changePercentage,
    required this.trendStatus,
    required this.message,
    required this.monthlyTrend,
  });

  final int selectedMonth;
  final int selectedYear;
  final TrendMonth? previousMonth;
  final TrendMonth currentMonth;
  final double changeAmount;
  final double changePercentage;
  final String trendStatus;
  final String message;
  final List<TrendMonth> monthlyTrend;

  factory SpendingTrend.fromJson(Map<String, dynamic> json) {
    return SpendingTrend(
      selectedMonth: int.parse(json['selectedMonth'].toString()),
      selectedYear: int.parse(json['selectedYear'].toString()),
      previousMonth:
          json['previousMonth'] == null
              ? null
              : TrendMonth.fromJson(json['previousMonth']),
      currentMonth: TrendMonth.fromJson(json['currentMonth']),
      changeAmount: double.parse(json['changeAmount'].toString()),
      changePercentage: double.parse(json['changePercentage'].toString()),
      trendStatus: json['trendStatus'].toString(),
      message: json['message'].toString(),
      monthlyTrend:
          (json['monthlyTrend'] as List)
              .map((item) => TrendMonth.fromJson(item))
              .toList(),
    );
  }
}

class TrendMonth {
  TrendMonth({
    required this.month,
    required this.year,
    required this.totalSpent,
    this.expenseCount = 0,
  });

  final int month;
  final int year;
  final double totalSpent;
  final int expenseCount;

  factory TrendMonth.fromJson(Map<String, dynamic> json) {
    return TrendMonth(
      month: int.parse(json['month'].toString()),
      year: int.parse(json['year'].toString()),
      totalSpent: double.parse(json['totalSpent'].toString()),
      expenseCount: int.parse((json['expenseCount'] ?? 0).toString()),
    );
  }
}
