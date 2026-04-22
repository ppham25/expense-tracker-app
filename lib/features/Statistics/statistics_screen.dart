import 'package:adv_basic/features/statistics/models/statistics_data.dart';
import 'package:adv_basic/features/statistics/services/statistics_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsService _statisticsService = StatisticsService();

  late int _selectedMonth;
  late int _selectedYear;

  bool _isLoading = true;
  StatisticsData? _statisticsData;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _loadStatistics();
  }

  List<FlSpot> get _dailySpendingSpots {
    if (_statisticsData == null) return [];

    return _statisticsData!.dailySpending
        .map((item) => FlSpot(item.day.toDouble(), item.amount))
        .toList();
  }

  Future<void> _loadStatistics() async {
    try {
      final statistics = await _statisticsService.getMonthlyStatistics(
        month: _selectedMonth,
        year: _selectedYear,
      );

      if (!mounted) return;
      setState(() {
        _statisticsData = statistics;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load statistics: $error')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMonthChanged(int? value) {
    if (value == null) return;

    setState(() {
      _selectedMonth = value;
      _isLoading = true;
    });

    _loadStatistics();
  }

  void _onYearChanged(int? value) {
    if (value == null) return;

    setState(() {
      _selectedYear = value;
      _isLoading = true;
    });

    _loadStatistics();
  }

  List<int> get _years {
    final currentYear = DateTime.now().year;
    return List.generate(5, (index) => currentYear - 2 + index);
  }

  List<DropdownMenuItem<int>> get _monthItems {
    return List.generate(
      12,
      (index) =>
          DropdownMenuItem(value: index + 1, child: Text('Month ${index + 1}')),
    );
  }

  List<DropdownMenuItem<int>> get _yearItems {
    return _years
        .map(
          (year) => DropdownMenuItem(value: year, child: Text(year.toString())),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No statistics available for this month.'),
    );

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_statisticsData != null) {
      content = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Spending Chart',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        minX: 1,
                        maxX: _statisticsData!.dailySpending.length.toDouble(),
                        minY: 0,
                        lineTouchData: const LineTouchData(enabled: true),
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 5,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _dailySpendingSpots,
                            isCurved: false,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Total Spent',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${_statisticsData!.monthlySummary.totalSpent.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Expenses Count',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _statisticsData!.monthlySummary.expenseCount
                              .toString(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Spending by Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._statisticsData!.categoryBreakdown.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(item.category.name.toUpperCase()),
                          ),
                          Text('\$${item.amount.toStringAsFixed(2)}'),
                          const SizedBox(width: 12),
                          Text('${item.percentage.toStringAsFixed(1)}%'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top 3 Biggest Expenses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_statisticsData!.topExpenses.isEmpty)
                    const Text('Không có khoản chi nào trong tháng này.')
                  else
                    ..._statisticsData!.topExpenses.map(
                      (expense) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(child: Text(expense.title)),
                            Text('\$${expense.amount.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedMonth,
                    items: _monthItems,
                    onChanged: _onMonthChanged,
                    decoration: const InputDecoration(labelText: 'Month'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    items: _yearItems,
                    onChanged: _onYearChanged,
                    decoration: const InputDecoration(labelText: 'Year'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}
