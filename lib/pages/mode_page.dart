import 'package:adapt/widgets/main_title.dart';
import 'package:adapt/widgets/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../enums/mood_period_filter.dart';
import '../models/mood.dart';
import '../services/localization_service.dart';
import '../services/mood_service.dart';
import '../utils/app_font_sizes.dart';
import '../widgets/feeling_chart.dart';
import '../widgets/motivation_chart.dart';

class ModePage extends StatefulWidget {
  bool shouldReload;

  ModePage({super.key, required this.shouldReload});

  @override
  _ModePageState createState() => _ModePageState();
}

class _ModePageState extends State<ModePage> {
  final log = Logger('ModePage');

  final MoodService _modeService = MoodService();

  static ModePeriodFilter selectedOption = ModePeriodFilter.thisMonth; // Default option
  DateTime? startDate;
  DateTime? endDate;

  void updateDateRange(ModePeriodFilter option) {
    Map<String, DateTime> period = getDateRange(option);
    selectedOption = option;
    startDate = period['start'];
    endDate = period['end'];
  }

  @override
  void initState() {
    super.initState();
    updateDateRange(ModePeriodFilter.thisMonth);
  }

  bool shouldReloadData = false;

  @override
  void didUpdateWidget(covariant ModePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the flag changed to true, meaning it should reload
    if (widget.shouldReload && !shouldReloadData) {
      setState(() {
        log.info('Mood Page state changed!!');
        shouldReloadData = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MainTitle(title: LocalizationService().get('mood')),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded( //Wrap the Column in Expanded
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedOption.value,
                            style: const TextStyle(
                              fontSize: AppFontSizes.small,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis, // <--- Add ellipsis for overflow
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${startDate.toString().substring(0, 10)} \u2013 ${endDate.toString().substring(0, 10)}',
                            style: const TextStyle(
                              fontSize: AppFontSizes.mini,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis, // Add ellipsis (optional)
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.access_time_filled_rounded,
                        color: Theme.of(context).primaryColorDark,
                        size: 35,
                      ),
                      onPressed: _showModalBottomSheet,
                    ),
                  ],
                ),
                Divider(
                  color: Theme.of(context).dividerColor,
                  // Customize the color as needed
                  thickness: 2.5, // Customize the thickness as needed
                ),

                // Use a SingleChildScrollView here to allow children to expand within constraints
                Expanded(
                    child: FutureBuilder<List<Mood>>(
                      future: _modeService.fetchModeList(startDate: startDate, endDate: endDate),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColorDark));
                        } else if (snapshot.hasError) {
                          return Center(child: Text(LocalizationService().get("error_loading_mood_data")));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text(LocalizationService().get("no_mood_data")));
                        }

                        final modeData = snapshot.data!;
                        //shouldReloadData = false;
                        widget.shouldReload = false;

                        return Column(
                          children: [
                            SubTitle(text: LocalizationService().get('Feeling')),
                            Expanded(
                              child: FeelingChart(modeData: modeData, startDate: startDate!, endDate: endDate!),
                            ),
                            Divider(
                              color: Theme.of(context).dividerColor,
                              thickness: 2.5,
                            ),
                            SubTitle(text: LocalizationService().get('Motivation')),
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

  void _showModalBottomSheet(){
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
                  Text(
                    LocalizationService().get('time_period'),
                    style: const TextStyle(
                      fontSize: AppFontSizes.small,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                    },
                  ),
                ],
              ),
              Divider(
                color: Theme.of(context).dividerColor,
                // Customize the color as needed
                thickness: 2.5, // Customize the thickness as needed
              ),
              // List of Options with Dividers
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: ModePeriodFilter.values.length,
                  itemBuilder: (context, index) {
                    final option = ModePeriodFilter.values[index];
                    return ListTile(
                      leading: Radio<ModePeriodFilter>(
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
                          option.value,
                          style: const TextStyle(
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
                    return Divider(
                      color: Theme.of(context).dividerColor,
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
}