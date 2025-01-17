import 'package:adapt/utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/mood.dart';
import '../services/mood_service.dart';

class MotivationChart extends StatelessWidget {
  final List<Mood> modeData;

  const MotivationChart({super.key, required this.modeData});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        minY: 0, // Set the minimum Y-axis value
        maxY: MoodService.maxMotivation.toDouble(), // Set the maximum Y-axis value to include all feelings (1-4)
        lineBarsData: [
          LineChartBarData(
            spots: modeData.map((data) => FlSpot(
              data.timeStamp.millisecondsSinceEpoch.toDouble(),
              data.motivation.toDouble(),
            )).toList(),
            isCurved: true,
            barWidth: 3,
            color: AppColors.primaryYellow,
            dotData: const FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(
            axisNameSize: 20,
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 30,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final modeDataDates = modeData.map((data) => data.timeStamp).toList();
                if (modeDataDates.isEmpty) return const SizedBox.shrink();

                // Sort the dates to find start and end
                modeDataDates.sort();
                final startDate = modeDataDates.first;
                final endDate = modeDataDates.last;

                // Determine evenly spaced labels
                const totalLabels = 10; // Total labels including start and end
                final interval = modeDataDates.length ~/ (totalLabels - 1);

                // Pick dates for labels
                final selectedDates = {
                  startDate,
                  ...List.generate(
                    totalLabels - 2,
                        (i) => modeDataDates[(i + 1) * interval.clamp(0, modeDataDates.length - 1)],
                  ),
                  endDate,
                }; // Ensure no duplicates

                final currentDate = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                if (selectedDates.any((date) => date.difference(currentDate).inDays == 0)) {
                  final monthNames = [
                    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
                  ];
                  final month = monthNames[currentDate.month - 1];
                  return Text(
                    '$month:${currentDate.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 10),
                  );
                }

                // Hide labels for dates not in the selected list
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}
