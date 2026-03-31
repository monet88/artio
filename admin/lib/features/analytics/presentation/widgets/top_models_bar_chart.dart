import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/analytics/domain/entities/analytics_stats.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TopModelsBarChart extends StatelessWidget {
  final List<ModelCount> topModels;

  const TopModelsBarChart({super.key, required this.topModels});

  @override
  Widget build(BuildContext context) {
    if (topModels.isEmpty) {
      return const Center(child: Text('No data'));
    }

    return BarChart(
      BarChartData(
        gridData: const FlGridData(),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= topModels.length) {
                  return const SizedBox.shrink();
                }
                final name = topModels[idx].model.split('/').last;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 9),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < topModels.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: topModels[i].count.toDouble(),
                  color: AdminColors.accent,
                  width: 24,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
