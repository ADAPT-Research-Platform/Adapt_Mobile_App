import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../enums/feeling.dart';
import '../models/mood.dart';

class FeelingChart extends StatelessWidget {
  final List<Mood> modeData;
  final DateTime startDate;
  final DateTime endDate;

  const FeelingChart({
    super.key,
    required this.modeData,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final allDates = List<DateTime>.generate(
      endDate.difference(startDate).inDays + 1,
          (i) => DateTime(
        startDate.year,
        startDate.month,
        startDate.day + i,
      ),
    );

    // Step 2: Map existing modeData to a map for quick lookup
    final modeDataMap = {
      for (var mood in modeData) mood.timeStamp: mood,
    };

    // Step 3: Create a new list with all dates, filling missing dates with a default Mood
    final completeModeData = allDates.map((date) {
      return modeDataMap[date] ??
          Mood(
            timeStamp: date,
            feeling: 0, // Default to "Unknown"
            motivation: 0,
          );
    }).toList();

    // Step 4: Configure BarChart
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        minY: 0, // Set the minimum Y-axis value
        maxY: 4, // Set the maximum Y-axis value to include all feelings (1-4)
        barGroups: completeModeData.map((data) {
          return BarChartGroupData(
            //barsSpace: 10,
            x: data.timeStamp.millisecondsSinceEpoch,
            barRods: [
              BarChartRodData(
                toY: data.feeling.toDouble(),
                color: Theme.of(context).primaryColorLight,
                width: 2,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            axisNameSize: 20,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: 1, // Show all feeling values
              getTitlesWidget: (value, _) {
                final int index = value.toInt();
                if (index >= 0 && index < Feeling.values.length) {
                  return Text(
                    Feeling.values[index].value, // Get the label from the enum
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const SizedBox.shrink(); // Return empty for invalid indices
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final modeDataDates = completeModeData.map((data) => data.timeStamp).toList();
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

