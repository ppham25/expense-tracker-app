import 'package:adv_basic/features/statistics/models/statistics_data.dart';
import 'package:adv_basic/features/statistics/services/statistics_service.dart';
import 'package:adv_basic/features/statistics/widgets/category_spend.dart';
import 'package:adv_basic/features/statistics/widgets/month_chart.dart';
import 'package:adv_basic/features/statistics/widgets/month_sum.dart';
import 'package:adv_basic/features/statistics/widgets/top_expenses.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:adv_basic/features/statistics/models/spending_trend.dart';
import 'package:adv_basic/features/statistics/widgets/spending_trend_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late int _selectedMonth;
  late int _selectedYear;
  var _isLoading = true;
  var _isExporting = false;
  SpendingTrend? _spendingTrend;
  StatisticsData? _statisticsData;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
    _selectedYear = DateTime.now().year;
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final service = StatisticsService();

      final statistics = await service.getMonthlyStatistics(
        month: _selectedMonth,
        year: _selectedYear,
      );

      final trend = await service.getSpendingTrend(
        month: _selectedMonth,
        year: _selectedYear,
      );

      if (!mounted) return;
      setState(() {
        _statisticsData = statistics;
        _spendingTrend = trend;
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

  Future<void> _exportReport() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final filePath = await StatisticsService().exportMonthlyReport(
        month: _selectedMonth,
        year: _selectedYear,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Xuất báo cáo thành công')));

      // ignore: deprecated_member_use
      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'Báo cáo chi tiêu tháng $_selectedMonth/$_selectedYear');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Xuất báo cáo thất bại: $e')));
    } finally {
      // ignore: control_flow_in_finally
      if (!mounted) return;

      setState(() {
        _isExporting = false;
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
            if (_spendingTrend != null)
              SpendingTrendCard(trend: _spendingTrend!),
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
                        _selectedYear = value;
                        _isLoading = true;
                      });

                      _loadStatistics();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _exportReport,
                icon:
                    _isExporting
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.file_download),
                label: Text(
                  _isExporting ? 'Đang xuất báo cáo...' : 'Xuất báo cáo CSV',
                ),
              ),
            ),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}
