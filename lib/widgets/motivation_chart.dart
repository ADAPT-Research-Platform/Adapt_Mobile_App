import 'package:adapt/utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/mode.dart';

class MotivationChart extends StatelessWidget {
  final List<Mode> modeData;

  const MotivationChart({super.key, required this.modeData});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: modeData.map((data) => FlSpot(
              data.timeStamp.millisecondsSinceEpoch.toDouble(),
              data.motivation.toDouble(),
            ))
                .toList(),
            isCurved: true,
            barWidth: 3,
            color: AppColors.darkYellow,
            dotData: FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text(
                  '${date.hour}:${date.minute}',
                  style: TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 30,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey, width: 1),
        ),
        gridData: FlGridData(show: true),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            //tooltipBgColor: Colors.black54,
          ),
        ),
      ),
    );
  }
}
