import 'package:adv_basic/features/statistics/models/statistics_data.dart';
import 'package:adv_basic/features/statistics/services/statistics_service.dart';
import 'package:adv_basic/features/statistics/widgets/category_spend.dart';
import 'package:adv_basic/features/statistics/widgets/month_chart.dart';
import 'package:adv_basic/features/statistics/widgets/month_sum.dart';
import 'package:adv_basic/features/statistics/widgets/top_expenses.dart';
import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late int _selectedMonth;
  late int _selectedYear;
  var _isLoading = true;
  StatisticsData? _statisticsData;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
    _selectedYear = DateTime.now().year;
    _loadStatistics();
    super.initState();
  }

  Future<void> _loadStatistics() async {
    try {
      final statistics = await StatisticsService().getMonthlyStatistics(
        month: _selectedMonth,
        year: _selectedYear,
      );

      if (!mounted) return;
      setState(() {
        _statisticsData = statistics;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load statistics: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<DropdownMenuItem<int>> get _monthItems {
    List<DropdownMenuItem<int>> items = [];
    for (int i = 1; i <= 12; i++) {
      items.add(DropdownMenuItem(value: i, child: Text('Tháng $i')));
    }
    return items;
  }

  List<DropdownMenuItem<int>> get _yearItems {
    List<DropdownMenuItem<int>> items = [];
    final currentYear = DateTime.now().year;
    for (int i = currentYear - 10; i <= currentYear; i++) {
      items.add(DropdownMenuItem(value: i, child: Text('Năm $i')));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text('No statistics available for this month.'),
    );

    if (_isLoading) {
      content = Center(child: CircularProgressIndicator());
    } else if (_statisticsData != null) {
      content = SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              child: MonthChart(dailySpend: _statisticsData!.dailySpending),
            ),
            SizedBox(height: 8),
            Text(
              'Monthly Chart ',
              style: Theme.of(context).textTheme.copyWith().titleLarge,
            ),
            MonthlySum(sumData: _statisticsData!.monthlySummary),
            CategorySpend(
              categoryBreakdown: _statisticsData!.categoryBreakdown,
            ),
            TopExpenses(topExpenses: _statisticsData!.topExpenses),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedMonth,
                    items: _monthItems,
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedMonth = value;
                        _isLoading = true;
                      });

                      _loadStatistics();
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedYear,
                    items: _yearItems,
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedMonth = value;
                        _isLoading = true;
                      });

                      _loadStatistics();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}
