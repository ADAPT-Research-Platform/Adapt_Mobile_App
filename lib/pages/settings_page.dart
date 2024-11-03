import 'package:adapt/utils/navigator_keys.dart';
import 'package:adapt/widgets/app_title_bar.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';
import '../utils/app_routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTitleBar(title: 'Settings'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                    globalNavigatorKey.currentState!.pushNamed(Routes.beehiveLogin);
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
            Divider(
              color: AppColors.lightGrey, // Customize the color as needed
              thickness: 2.5, // Customize the thickness as needed
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
            Divider(
              color: AppColors.lightGrey, // Customize the color as needed
              thickness: 2.5, // Customize the thickness as needed
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
