import 'package:adapt/services/session_manager.dart';
import 'package:adapt/widgets/main_title.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';
import '../widgets/sub_title.dart';
import '../widgets/task_button.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});


  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  // State variables for the appearance section
  String _selectedLanguage = 'German'; // Default selected language
  String _selectedTheme = 'System'; // Default selected theme

  // State variables for the notifications section
  bool _isNotificationSoundEnabled = true;
  bool _isMuteNotifications = false;

  @override
  void dispose() {
    _userNameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _saveData() async {
    String userName = _userNameController.text.trim();
    String oldPassword = _oldPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();

    print('Account Data: $userName, $oldPassword, $newPassword');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainTitle(title: 'Settings'),
      body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView(
              children: [
                const SubTitle(text: 'Account'),
                const SizedBox(height: 10),
                const Text(
                  'User Name',
                  style: TextStyle(
                    color: AppColors.fontColor,
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    labelText: SessionManager().sessionUser?.userName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Email Address',
                  style: TextStyle(
                    color: AppColors.fontColor,
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: SessionManager().sessionUser?.email,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Old Password',
                  style: TextStyle(
                    color: AppColors.fontColor,
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                ),
                const Text(
                  'New Password',
                  style: TextStyle(
                    color: AppColors.fontColor,
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TaskButton(
                        text: 'Update',
                        onPressed: _saveData,
                        icon: Icons.update_rounded,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child:  TaskButton(
                        text: 'Delete',
                        onPressed: () {
                          // Delete action
                        },
                        backgroundColor: AppColors.darkYellow,
                        icon: Icons.delete_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Divider(
                  color: AppColors.lightGrey,
                  thickness: 2.5,
                ),
                const SubTitle(text: 'Appearance'),
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
                const SubTitle(text: 'Notifications'),
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
                const SizedBox(height: 5),
                // Logout button at the bottom
                TaskButton(
                    text: 'Logout',
                    onPressed: () {
                      _authService.logout();
                    },
                  icon: Icons.logout_rounded,
                ),
                const SizedBox(height: 15),
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
