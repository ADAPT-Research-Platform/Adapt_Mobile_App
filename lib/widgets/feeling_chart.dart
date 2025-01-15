import 'package:adapt/utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/mood.dart';

class FeelingChart extends StatelessWidget {
  final List<Mood> modeData;

  const FeelingChart({super.key, required this.modeData});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: modeData.map((data) {
          return BarChartGroupData(
            x: data.timeStamp.millisecondsSinceEpoch,
            barRods: [
              BarChartRodData(
                toY: data.feeling.toDouble(),
                color: AppColors.primaryYellow,
                width: 25,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1, // Only show integers on the Y-axis
              getTitlesWidget: (value, _) {
                if (value == 1 || value == 2 || value == 3 || value == 4) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(fontSize: 10),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text(
                  '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
