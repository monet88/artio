import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Data for one slice of the tier pie chart.
class TierPieSection {
  const TierPieSection({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;
}

/// Reusable pie chart for subscription tier distribution.
/// Used by both Analytics and Revenue pages.
class TierPieChart extends StatelessWidget {
  final List<TierPieSection> sections;

  const TierPieChart({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    final total = sections.fold<int>(0, (sum, s) => sum + s.count);
    if (total == 0) {
      return const Center(child: Text('No data'));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 48,
        sections: sections.map((s) {
          return PieChartSectionData(
            value: s.count.toDouble(),
            title: '${s.label}\n${s.count}',
            color: s.color,
            radius: 56,
            titleStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }
}
