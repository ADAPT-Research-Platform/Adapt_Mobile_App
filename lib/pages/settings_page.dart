import 'package:adapt/services/session_manager.dart';
import 'package:adapt/services/user_service.dart';
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
  final UserService _userService = UserService();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  bool _changePassword = false; // Toggle for the collapsible password fields
  // State variables for the appearance section
  String _selectedLanguage = 'German'; // Default selected language
  String _selectedTheme = 'System'; // Default selected theme

  // State variables for the notifications section
  bool _isNotificationSoundEnabled = true;
  bool _isMuteNotifications = false;

  @override
  void initState() {
    super.initState();
    _userNameController.text = SessionManager().sessionUser!.userName;
    _emailController.text = SessionManager().sessionUser!.email;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _updateUser() async {
    String userName = _userNameController.text.trim();
    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmNewPassword = _confirmNewPasswordController.text.trim();

    _userService.updateUser(userName, currentPassword, newPassword, confirmNewPassword);
  }

  void _deleteUser() async {
    String currentPassword = _currentPasswordController.text.trim();

    _userService.deleteUser(currentPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            const SubTitle(text: 'Account'),
            const SizedBox(height: 10),
            _buildTextField('User Name', _userNameController),
            const SizedBox(height: 10),
            _buildTextField('Email Address', _emailController, enabled: false),
            const SizedBox(height: 10),

            // Checkbox for Change Password
            Row(
              children: [
                Checkbox(
                  value: _changePassword,
                  onChanged: (value) {
                    setState(() {
                      _changePassword = value!;
                    });
                  },
                ),
                const Text(
                  'Change Password',
                  style: TextStyle(
                    color: AppColors.fontColor,
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Collapsible password fields
            if (_changePassword) ...[
              _buildTextField('Current Password', _currentPasswordController, obscureText: true),
              const SizedBox(height: 10),
              _buildTextField('New Password', _newPasswordController, obscureText: true),
              const SizedBox(height: 10),
              _buildTextField('Confirm New Password', _confirmNewPasswordController, obscureText: true),
              const SizedBox(height: 15),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TaskButton(
                    text: 'Update',
                    onPressed: _updateUser,
                    icon: Icons.update_rounded,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TaskButton(
                    text: 'Delete',
                    onPressed: _deleteUser,
                    backgroundColor: AppColors.darkYellow,
                    icon: Icons.delete_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(color: AppColors.lightGrey, thickness: 2.5),
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
  // Reusable widget for label and text field
  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true, bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.fontColor,
            fontSize: AppFontSizes.small,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
          ),
        ),
      ],
    );
  }

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
