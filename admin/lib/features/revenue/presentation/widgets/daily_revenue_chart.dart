import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/revenue/domain/entities/revenue_stats.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyRevenueChart extends StatelessWidget {
  final List<DailyRevenue> dailyRevenue;

  const DailyRevenueChart({super.key, required this.dailyRevenue});

  @override
  Widget build(BuildContext context) {
    if (dailyRevenue.isEmpty || dailyRevenue.every((d) => d.transactionCount == 0)) {
      return const Center(child: Text('No data'));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= dailyRevenue.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat.Md().format(dailyRevenue[idx].date),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < dailyRevenue.length; i++)
                FlSpot(
                  i.toDouble(),
                  dailyRevenue[i].transactionCount.toDouble(),
                ),
            ],
            isCurved: true,
            color: AdminColors.statAmber,
            belowBarData: BarAreaData(
              show: true,
              color: AdminColors.statAmber.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
