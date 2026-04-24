import 'dart:math';

import 'package:adv_basic/features/statistics/models/statistics_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthChart extends StatelessWidget {
  const MonthChart({super.key, required this.dailySpend});

  final List<DailySpendingItem> dailySpend;

  double get maxAmount {
    double maxA = 0;
    for (var item in dailySpend) {
      maxA = max(maxA, item.amount);
    }
    maxA = maxA == 0 ? 100.0 : maxA * 1.2;
    return maxA;
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    for (var item in dailySpend) {
      spots.add(FlSpot(item.day.toDouble(), item.amount));
    }
    return LineChart(
      LineChartData(
        minX: 1,
        maxX: dailySpend.length.toDouble(),
        minY: 0,
        maxY: maxAmount,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),

        lineBarsData: [
          LineChartBarData(
            spots: spots,
            barWidth: 3,
            color: const Color.fromARGB(255, 3, 43, 75),
            dotData: FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 150,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}N VNĐ'),
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}
