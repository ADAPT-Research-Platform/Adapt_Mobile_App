import 'package:adapt/services/session_manager.dart';
import 'package:adapt/services/user_service.dart';
import 'package:adapt/widgets/main_title.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../services/auth_service.dart';
import '../services/localization_service.dart';
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
  final log = Logger('SettingsPage');

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _confirmCurrentPasswordController = TextEditingController();
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
    _userNameController.text = 'Loading...';
    _emailController.text = 'Loading...';
    _initializeUserData(); // Call an async helper method
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _confirmCurrentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _initializeUserData() async {
    final sessionUser = await SessionManager().getSessionUser();
    if (sessionUser != null) {
      setState(() {
        _userNameController.text = sessionUser.userName;
        _emailController.text = sessionUser.email;
      });
    }
  }

  void _updateUser() async {
    String userName = _userNameController.text.trim();
    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmNewPassword = _confirmNewPasswordController.text.trim();

    _userService.updateUser(userName, currentPassword, newPassword, confirmNewPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainTitle(title: LocalizationService().get('settings')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            SubTitle(text: LocalizationService().get('Account')),
            const SizedBox(height: 10),
            _buildTextField(LocalizationService().get('user_name'), _userNameController),
            const SizedBox(height: 10),
            _buildTextField(LocalizationService().get('email_address'), _emailController, enabled: false),
            const SizedBox(height: 10),

            // Checkbox for Change Password
            Row(
              children: [
                Checkbox(
                  value: _changePassword,
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.darkYellow;
                    }
                    return null;
                  }),
                  onChanged: (value) {
                    setState(() {
                      _changePassword = value!;

                      if(!_changePassword){
                        _currentPasswordController.clear();
                        _newPasswordController.clear();
                        _confirmNewPasswordController.clear();
                      }
                    });
                  },
                ),
                Text(
                  LocalizationService().get('change_password'),
                  style: const TextStyle(
                    color: AppColors.fontColor,
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Collapsible password fields
            if (_changePassword) ...[
              _buildTextField(LocalizationService().get('current_password'), _currentPasswordController, obscureText: true),
              const SizedBox(height: 10),
              _buildTextField(LocalizationService().get('new_password'), _newPasswordController, obscureText: true),
              const SizedBox(height: 10),
              _buildTextField(LocalizationService().get('confirm_new_password'), _confirmNewPasswordController, obscureText: true),
              const SizedBox(height: 15),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TaskButton(
                    text: LocalizationService().get('Update'),
                    onPressed: _updateUser,
                    icon: Icons.update_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TaskButton(
                    text: LocalizationService().get('Delete'),
                    onPressed: _showDeleteConfirmationDialog,
                    backgroundColor: AppColors.darkYellow,
                    icon: Icons.delete_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(color: AppColors.lightGrey, thickness: 2.5),
            SubTitle(text: LocalizationService().get('Appearance')),
            _buildRadioOption(LocalizationService().get('Language'), ['Deutch', 'English'], _selectedLanguage, (value) {
              setState(() {
                _selectedLanguage = value!;
                String languageCode = _selectedLanguage == 'English' ? 'en' : 'de';
                LocalizationService().load(languageCode);
              });
            }),
            _buildRadioOption(LocalizationService().get('Theme'), ['System', 'Light', 'Dark'], _selectedTheme, (value) {
              setState(() {
                _selectedTheme = value!;
              });
            }),

            const Divider(
              color: AppColors.lightGrey,
              thickness: 2.5,
            ),
            SubTitle(text: LocalizationService().get('Notifications')),
            _buildSwitchOption(LocalizationService().get('mute_notifications'), _isMuteNotifications, (value) {
              setState(() {
                _isMuteNotifications = value;
              });
            }),
            _buildSwitchOption(LocalizationService().get('notification_sound'), _isNotificationSoundEnabled, (value) {
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
              text: LocalizationService().get('Logout'),
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
  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true, bool obscureText = false}) {
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

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(16), // Dialog padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SubTitle(text: LocalizationService().get('Delete'))
                ),
                const SizedBox(height: 10),
                _buildTextField(LocalizationService().get('current_password'), _confirmCurrentPasswordController, obscureText: true),
                const SizedBox(height: 10),
                // Confirm button
                Align(
                  alignment: Alignment.center,
                  child: TaskButton(
                    text: LocalizationService().get('Confirm'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      _userService.deleteUser(_confirmCurrentPasswordController.text.trim());
                      _confirmCurrentPasswordController.clear();
                    },
                    backgroundColor: AppColors.darkYellow,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
