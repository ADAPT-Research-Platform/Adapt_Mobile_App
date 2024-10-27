import 'package:adapt/widgets/app_title_bar.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTitleBar(title: 'Settings'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ListView(
          children: [
            const Center(
              child: Text(
                'Account',
                style: TextStyle(
                  color: AppColors.darkYellow, // Static text color
                  fontSize: AppFontSizes.medium, // Static font size
                  fontWeight: FontWeight.bold, // Static font weight
                ),
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Logout action
                  },
                  icon: Icon(Icons.save),
                  label: Text(
                    'Save',
                    style: const TextStyle(
                      fontSize: AppFontSizes.small,
                      fontWeight: FontWeight.bold, // Static font size
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(double.infinity, 50),
                    foregroundColor: AppColors.white,
                    backgroundColor: AppColors.primaryYellow,
                    // Set size for square button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6), // Round edges
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Logout action
                  },
                  icon: Icon(Icons.delete),
                  label: Text(
                    'Delete',
                    style: const TextStyle(
                      fontSize: AppFontSizes.small,
                      fontWeight: FontWeight.bold, // Static font size
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(double.infinity, 50),
                    foregroundColor: AppColors.white,
                    backgroundColor: AppColors.darkYellow,
                    // Set size for square button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6), // Round edges
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    // Logout action
                  },
                  icon: Icon(Icons.logout),
                  label: Text(
                    'Logout',
                    style: const TextStyle(
                      fontSize: AppFontSizes.small,
                      fontWeight: FontWeight.bold, // Static font size
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(double.infinity, 50),
                    foregroundColor: AppColors.white,
                    backgroundColor: AppColors.primaryYellow,
                    // Set size for square button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6), // Round edges
                    ),
                  ),
                ),
              ],
            ),
            Container(
                padding: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                        bottom: BorderSide(
                            color: AppColors.lightGrey, width: 2.5)))
            ),
            Center(
              child: Text(
                'Appearance',
                style: const TextStyle(
                  color: AppColors.darkYellow, // Static text color
                  fontSize: AppFontSizes.medium, // Static font size
                  fontWeight: FontWeight.bold, // Static font weight
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                        bottom: BorderSide(
                            color: AppColors.lightGrey, width: 2.5)))
            ),
            Center(
              child: Text(
                'Notifications',
                style: const TextStyle(
                  color: AppColors.darkYellow, // Static text color
                  fontSize: AppFontSizes.medium, // Static font size
                  fontWeight: FontWeight.bold, // Static font weight
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
