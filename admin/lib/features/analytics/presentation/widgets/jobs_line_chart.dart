import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/analytics/domain/entities/analytics_stats.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyJobsLineChart extends StatelessWidget {
  final List<DailyCount> dailyJobs;

  const DailyJobsLineChart({super.key, required this.dailyJobs});

  @override
  Widget build(BuildContext context) {
    if (dailyJobs.isEmpty) {
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
                if (idx < 0 || idx >= dailyJobs.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat.Md().format(dailyJobs[idx].date),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
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
              for (var i = 0; i < dailyJobs.length; i++)
                FlSpot(i.toDouble(), dailyJobs[i].count.toDouble()),
            ],
            isCurved: true,
            color: AdminColors.primary,
            belowBarData: BarAreaData(
              show: true,
              color: AdminColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
