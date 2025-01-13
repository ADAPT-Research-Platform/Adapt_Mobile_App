import 'package:adapt/widgets/main_title.dart';
import 'package:adapt/widgets/sub_title.dart';
import 'package:flutter/material.dart';

import '../models/mode.dart';
import '../services/mode_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';
import '../utils/filter_options.dart';
import '../widgets/feeling_chart.dart';
import '../widgets/motivation_chart.dart';

class ModePage extends StatefulWidget {
  const ModePage({super.key});

  @override
  _ModePageState createState() => _ModePageState();
}

class _ModePageState extends State<ModePage> {
  final ModeService _modeService = ModeService();

  FilterOption? selectedOption; // Default option
  DateTime? startDate;
  DateTime? endDate;

  void updateDateRange(FilterOption option) {
    Map<String, DateTime> period = getDateRange(option);
    selectedOption = option;
    startDate = period['start'];
    endDate = period['end'];
  }

  @override
  void initState() {
    super.initState();
    updateDateRange(FilterOption.thisMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const MainTitle(title: 'Mood'),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      filterOptionLabels[selectedOption]!,
                      style: const TextStyle(
                        color: AppColors.fontColor,
                        fontSize: AppFontSizes.small,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('${startDate.toString().substring(0, 10)} - ${endDate.toString().substring(0, 10)}',
                        style: const TextStyle(
                        color: AppColors.fontColor,
                        fontSize: AppFontSizes.small
                    )),
                    IconButton(
                      icon: const Icon(Icons.access_time, color: AppColors.darkYellow, size: 35), // Static color
                        onPressed: () {
                          showModalBottomSheet(
                            useSafeArea: true,
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12.0)), // Adjust the top corners
                            ),
                            builder: (BuildContext context) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                        // Title with Close Button
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const SizedBox(width: 24), // Placeholder to align the title center
                                            const Text(
                                              'Time Period',
                                              style: TextStyle(
                                                color: AppColors.fontColor,
                                                fontSize: AppFontSizes.small,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () {
                                                Navigator.pop(context); // Close the bottom sheet
                                              },
                                            ),
                                          ],
                                        ),
                                        const Divider(
                                          color: AppColors.lightGrey,
                                          // Customize the color as needed
                                          thickness: 2.5, // Customize the thickness as needed
                                        ),
                                        // List of Options with Dividers
                                        Flexible(
                                          child: ListView.separated(
                                            shrinkWrap: true,
                                            itemCount: FilterOption.values.length,
                                            itemBuilder: (context, index) {
                                              final option = FilterOption.values[index];
                                              return ListTile(
                                                leading: Radio<FilterOption>(
                                                  value: option,
                                                  groupValue: selectedOption,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      updateDateRange(value!);
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                title: Text(
                                                    filterOptionLabels[option]!,
                                                    style: const TextStyle(
                                                    color: AppColors.fontColor,
                                                    fontSize: AppFontSizes.small
                                                )),
                                                onTap: () {
                                                  setState(() {
                                                    updateDateRange(option);
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                            separatorBuilder: (context, index) {
                                              return const Divider(
                                                color: AppColors.lightGrey,
                                                thickness: 2.5,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                            },
                          );
                        }
                    ),
                  ],
                ),
                const Divider(
                  color: AppColors.lightGrey,
                  // Customize the color as needed
                  thickness: 2.5, // Customize the thickness as needed
                ),

                // Use a SingleChildScrollView here to allow children to expand within constraints
                Expanded(
                    child: FutureBuilder<List<Mode>>(
                      future: _modeService.fetchModeList(startDate: startDate, endDate: endDate),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: AppColors.darkYellow),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(child: Text("Error loading mood data"));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text("No mood data available"));
                        }

                        final modeData = snapshot.data!;

                        return Column(
                          children: [
                            const SubTitle(text: 'Feeling'),
                            Expanded(
                              child: FeelingChart(modeData: modeData),
                            ),
                            const Divider(
                              color: AppColors.lightGrey,
                              thickness: 2.5,
                            ),
                            const SubTitle(text: 'Motivation'),
                            Expanded(
                              child: MotivationChart(modeData: modeData),
                            ),
                          ],
                        );
                      },
                    )
                ),
              ],
            ),
          ),
    );
  }
}