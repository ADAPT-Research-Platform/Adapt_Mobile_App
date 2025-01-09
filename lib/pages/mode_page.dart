import 'package:adapt/widgets/main_title.dart';
import 'package:adapt/widgets/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../models/mode.dart';
import '../services/firebase_mode_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';
import '../utils/filter_options.dart';
import '../widgets/feeling_chart.dart';
import '../widgets/motivation_chart.dart';
import '../widgets/task_button.dart';

class ModePage extends StatefulWidget {
  const ModePage({super.key});

  @override
  _ModePageState createState() => _ModePageState();
}

class _ModePageState extends State<ModePage> {
  final ScrollController _scrollController = ScrollController();
  final FirebaseModeService _firebaseModeService = FirebaseModeService();

  FilterOption selectedOption = FilterOption.thisMonth; // Default option

  void handleApplyButtonClick() {
    // Print the date range in the desired format
    print(getDateRangeString(selectedOption));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const MainTitle(title: 'Mood'),
        body: FutureBuilder<List<Mode>>(
            future: _firebaseModeService.fetchModeList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.darkYellow));
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Error loading mode tracking data"));
              }

              final modeData = snapshot.data!;

              return Padding(
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
                        Text(getDateRangeString(selectedOption), style: const TextStyle(
                            color: AppColors.fontColor,
                            fontSize: AppFontSizes.small
                        )),
                        IconButton(
                          icon: const Icon(Icons.access_time, color: AppColors.darkYellow, size: 35), // Static color
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true, // Allows the bottom sheet to adjust height
                                builder: (BuildContext context) {
                                  return LayoutBuilder(
                                    builder: (context, constraints) {
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
                                                separatorBuilder: (context, index) => const Divider(
                                                  color: AppColors.lightGrey,
                                                  // Customize the color as needed
                                                  thickness: 2.5, // Customize the thickness as needed
                                                ),
                                                itemBuilder: (context, index) {
                                                  final option = FilterOption.values[index];
                                                  return ListTile(
                                                    leading: Radio<FilterOption>(
                                                      value: option,
                                                      groupValue: selectedOption,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedOption = value!;
                                                        });
                                                        print(getDateRangeString(selectedOption));
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
                                                        selectedOption = option;
                                                      });
                                                      print(getDateRangeString(selectedOption));
                                                      Navigator.pop(context);
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
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
                    const SubTitle(text: 'Feeling'),
                    Expanded(
                      child: FeelingChart(modeData: modeData),
                    ),
                    const Divider(
                      color: AppColors.lightGrey,
                      // Customize the color as needed
                      thickness: 2.5, // Customize the thickness as needed
                    ),
                    const SubTitle(text: 'Motivation'),
                    Expanded(
                      child: MotivationChart(modeData: modeData),
                    ),
                  ],
                ),
              );
            }));
  }
}