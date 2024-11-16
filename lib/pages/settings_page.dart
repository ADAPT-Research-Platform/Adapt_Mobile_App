import 'package:adapt/utils/navigator_keys.dart';
import 'package:adapt/widgets/app_title_bar.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';
import '../utils/app_routes.dart';

class SettingsPage extends StatefulWidget {

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // State variables for the appearance section
  String _selectedLanguage = 'German'; // Default selected language
  String _selectedTheme = 'System'; // Default selected theme

  // State variables for the notifications section
  bool _isNotificationSoundEnabled = true;
  bool _isMuteNotifications = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;

    return Scaffold(
      appBar: AppTitleBar(title: 'Settings'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            const Center(
              child: Text(
                'Account',
                style: TextStyle(
                  color: AppColors.darkYellow,
                  fontSize: AppFontSizes.medium,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Save action
                    },
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: AppFontSizes.small,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50), // Smaller height for buttons
                      foregroundColor: AppColors.white,
                      backgroundColor: AppColors.primaryYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Delete action
                    },
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: AppFontSizes.small,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      foregroundColor: AppColors.white,
                      backgroundColor: AppColors.darkYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              color: AppColors.lightGrey,
              thickness: 2.5,
            ),
            const Center(
              child: Text(
                'Appearance',
                style: TextStyle(
                  color: AppColors.darkYellow,
                  fontSize: AppFontSizes.medium,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildRadioOption('Language', ['German', 'English'], _selectedLanguage, (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            }),
            _buildRadioOption('Theme', ['System', 'Light', 'Dark'], _selectedTheme, (value) {
              setState(() {
                _selectedTheme = value!;
              });
            }),


            const Divider(
              color: AppColors.lightGrey,
              thickness: 2.5,
            ),
            const Center(
              child: Text(
                'Notifications',
                style: TextStyle(
                  color: AppColors.darkYellow,
                  fontSize: AppFontSizes.medium,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildSwitchOption('Mute Notifications', _isMuteNotifications, (value) {
              setState(() {
                _isMuteNotifications = value;
              });
            }),
            _buildSwitchOption('Notification Sound', _isNotificationSoundEnabled, (value) {
              setState(() {
                _isNotificationSoundEnabled = value;
              });
            }),
            const Divider(
              color: AppColors.lightGrey,
              thickness: 2.5,
            ),
            // Logout button at the bottom
            ElevatedButton.icon(
                onPressed: () {
                  mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // Full-width button
                  foregroundColor: AppColors.white,
                  backgroundColor: AppColors.primaryYellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  //TODO: Move this to a separate widget later
  Widget _buildRadioOption(String title, List<String> options, String selectedValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.fontColor,
              fontSize: AppFontSizes.small,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: options.map((option) {
            return Row(
              children: [
                Radio<String>(
                  value: option,
                  groupValue: selectedValue,
                  onChanged: onChanged,
                  activeColor: Colors.amber,
                ),
                Text(option, style: const TextStyle(
                  color: AppColors.fontColor,
                  fontSize: AppFontSizes.small
                )),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  //TODO: Move this to a separate widget later
  Widget _buildSwitchOption(String title, bool currentValue, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(
          color: AppColors.fontColor,
          fontSize: AppFontSizes.small
      )),
      value: currentValue,
      onChanged: onChanged,
      activeColor: AppColors.primaryYellow,
    );
  }
}
