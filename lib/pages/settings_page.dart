import 'package:adapt/enums/language.dart';
import 'package:adapt/enums/theme_type.dart';
import 'package:adapt/services/session_manager.dart';
import 'package:adapt/services/user_service.dart';
import 'package:adapt/widgets/main_title.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../services/auth_service.dart';
import '../services/localization_service.dart';
import '../services/notification_service.dart';
import '../utils/app_font_sizes.dart';
import '../utils/app_keys.dart';
import '../widgets/snack_bar_shower.dart';
import '../widgets/sub_title.dart';
import '../widgets/task_button.dart';

class SettingsPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const SettingsPage({super.key, required this.onThemeChanged});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final log = Logger('SettingsPage');

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _confirmCurrentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  bool _changePassword = false; // Toggle for the collapsible password fields
  // State variables for the appearance section
  Language _selectedLanguage = Language.german; // Default selected language
  ThemeType _selectedTheme = ThemeType.system; // Default selected theme

  // State variables for the notifications section
  bool _isNotificationSoundEnabled = true;
  bool _isMuteNotifications = false;
  TimeOfDay? _selectedNotificationTime; // For storing the selected notification time

  @override
  void initState() {
    super.initState();
    _userNameController.text = 'Loading...';
    _initializeUserData(); // Call an async helper method
    _loadNotificationTime(); // Load the notification time
  }

  @override
  void dispose() {
    _userNameController.dispose();
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
      });
    }

    _selectedTheme = await SessionManager().getSelectedThemeType();
    _selectedLanguage = await SessionManager().getSelectedLanguage();
  }

  void _updateUser() async {
    String userName = _userNameController.text.trim();
    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmNewPassword = _confirmNewPasswordController.text.trim();

    _userService.updateUser(userName, currentPassword, newPassword, confirmNewPassword);
  }

  Future<void> _loadNotificationTime() async {
    // Load the stored notification time
    final storedTime = await NotificationService.getScheduledTime();
    if (storedTime != null) {
      final parts = storedTime.split(':');
      setState(() {
        _selectedNotificationTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      });
    }
  }

  Future<void> _pickNotificationTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedNotificationTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.inputOnly
    );
    if (pickedTime != null) {
      setState(() {
        _selectedNotificationTime = pickedTime;
      });

      // Schedule the notification with the selected time
      await NotificationService.updateScheduledTime(
        1,
        LocalizationService().get("notification_title"),
        LocalizationService().get("notification_text"),
        pickedTime,
      );

      SnackBarShower.info(settingPageScaffold, "${LocalizationService().get('notification_schedule')} ${pickedTime.format(context)}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: settingPageScaffold,
      child: Scaffold(
        appBar: MainTitle(title: LocalizationService().get('settings')),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              SubTitle(text: LocalizationService().get('Account')),
              const SizedBox(height: 10),
              _buildTextField(LocalizationService().get('user_name'), _userNameController),
              const SizedBox(height: 10),

              // Checkbox for Change Password
              Row(
                children: [
                  Checkbox(
                    value: _changePassword,
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Theme.of(context).primaryColorDark;
                      }
                      return null;
                    }),
                    onChanged: (value) {
                      setState(() {
                        _changePassword = value!;

                        if (!_changePassword) {
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
                      backgroundColor: Theme.of(context).primaryColorDark,
                      icon: Icons.delete_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Divider(color: Theme.of(context).dividerColor, thickness: 2.5),
              SubTitle(text: LocalizationService().get('Appearance')),
              _buildRadioOption<Language>(LocalizationService().get('Language'), Language.values, _selectedLanguage, (option) => option.value, (value) {
                  setState(() {
                    _selectedLanguage = value!;
                    String languageCode = _selectedLanguage == Language.english ? 'en' : 'de';
                    LocalizationService().load(languageCode);

                    SessionManager().setSelectedLanguage(_selectedLanguage);
                  });
                },
              ),
              _buildRadioOption<ThemeType>(LocalizationService().get('Theme'), ThemeType.values, _selectedTheme, (option) => option.value, (value) {
                  setState(() {
                    _selectedTheme = value!;
                    if (value == ThemeType.light) {
                      widget.onThemeChanged(ThemeMode.light);
                    } else if (value == ThemeType.dark) {
                      widget.onThemeChanged(ThemeMode.dark);
                    } else {
                      widget.onThemeChanged(ThemeMode.system);
                    }

                    SessionManager().setSelectedThemeType(_selectedTheme);
                  });
                },
              ),
              Divider(color: Theme.of(context).dividerColor, thickness: 2.5),
              SubTitle(text: LocalizationService().get('Notifications')),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0), // Consistent padding
                dense: true, // Makes the tile vertically compact, like SwitchListTile
                title: Text(
                  LocalizationService().get('scheduled_time'),
                  style: const TextStyle(fontSize: AppFontSizes.small),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis
                ),
                trailing: ElevatedButton(
                  onPressed: _selectedNotificationTime == null ? null : _pickNotificationTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    foregroundColor: Theme.of(context).primaryColorDark,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: _selectedNotificationTime == null
                    // Show a loading indicator while fetching
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    )
                    // Show the time once it's loaded
                    : Text(
                      _selectedNotificationTime!.format(context),
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 10
                      ),
                    ),
                ),
              ),
              _buildSwitchOption(
                  LocalizationService().get('mute_notifications'),
                  _isMuteNotifications, (value) {
                    setState(() {
                      _isMuteNotifications = value;
                    });
                  }
              ),
              _buildSwitchOption(
                  LocalizationService().get('notification_sound'),
                  _isNotificationSoundEnabled, (value) {
                    setState(() {
                      _isNotificationSoundEnabled = value;
                    });
                  }
              ),
              Divider(
                color: Theme.of(context).dividerColor,
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
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true, bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
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
            isDense: true,
          ),
        ),

      ],
    );
  }

  Widget _buildRadioOption<T>(String title, List<T> options, T selectedValue, String Function(T) getValue, void Function(T?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: AppFontSizes.small,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 0.0), // Indent the radio options slightly
          child: Wrap(
            spacing: 0.0,
            runSpacing: 0.0,
            alignment: WrapAlignment.start, // Align children to the start
            children: options.map((option) {
              return Row(
                mainAxisSize: MainAxisSize.min, // Crucial for Wrap to calculate child size correctly
                children: [
                  Radio<T>(
                    value: option,
                    groupValue: selectedValue,
                    onChanged: onChanged,
                    activeColor: Theme.of(context).primaryColorLight,
                  ),
                  Flexible( // Use Flexible to allow the text to wrap if it's extremely long
                    child: Text(
                      getValue(option),
                      style: const TextStyle(fontSize: AppFontSizes.small),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchOption(String title, bool currentValue, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title,
          style: const TextStyle(fontSize: AppFontSizes.small)
      ),
      value: currentValue,
      onChanged: onChanged,
      activeThumbColor: Theme.of(context).primaryColorLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      dense: true,
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
                    child: SubTitle(text: LocalizationService().get('Delete'))),
                const SizedBox(height: 10),
                _buildTextField(LocalizationService().get('current_password'),
                    _confirmCurrentPasswordController,
                    obscureText: true),
                const SizedBox(height: 10),
                // Confirm button
                Align(
                  alignment: Alignment.center,
                  child: TaskButton(
                    text: LocalizationService().get('Confirm'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      _userService.deleteUser(
                          _confirmCurrentPasswordController.text.trim());
                      _confirmCurrentPasswordController.clear();
                    },
                    backgroundColor: Theme.of(context).primaryColorDark,
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
