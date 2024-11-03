import 'package:adapt/utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/mode.dart';

class FeelingChart extends StatelessWidget {
  final List<Mode> modeData;

  const FeelingChart({super.key, required this.modeData});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: modeData.map((data) {
          return BarChartGroupData(
            x: data.timeStamp.millisecondsSinceEpoch,
            barRods: [
              BarChartRodData(
                toY: data.feeling.toDouble(),
                color: AppColors.primaryYellow,
                width: 15,
                borderRadius: BorderRadius.circular(4),
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
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey, width: 1),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: 1,
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            //tooltipBgColor: Colors.black54,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = DateTime.fromMillisecondsSinceEpoch(group.x.toInt());
              return BarTooltipItem(
                '${date.hour}:${date.minute.toString().padLeft(2, '0')}\nFeeling: ${rod.toY.toInt()}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}
