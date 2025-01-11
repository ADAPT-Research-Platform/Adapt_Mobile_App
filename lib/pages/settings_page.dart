import 'package:adapt/widgets/main_title.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
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

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variables for the appearance section
  String _selectedLanguage = 'German'; // Default selected language
  String _selectedTheme = 'System'; // Default selected theme

  // State variables for the notifications section
  bool _isNotificationSoundEnabled = true;
  bool _isMuteNotifications = false;

  late Future<User> _loggedInUser; // Declare the Future

  @override
  void initState() {
    super.initState();
    _loggedInUser = _authService.getLoggedInUser(); // Initialize the Future
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _userEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveData() async {
    String displayName = _displayNameController.text.trim();
    String userEmail = _userEmailController.text.trim();
    String password = _passwordController.text.trim();

    print('Account Data: $displayName, $userEmail, $password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainTitle(title: 'Settings'),
      body: FutureBuilder<User>(
        future: _loggedInUser, // Use the initialized Future here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.darkYellow));
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading modules"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No modules available"));
          }

          final user = snapshot.data!;

          return  Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView(
              children: [
                const SubTitle(text: 'Account'),
                const SizedBox(height: 10),
                const Text(
                  'User Code',
                  style: TextStyle(
                    color: AppColors.fontColor,
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: user.userName.toString(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Display Name',
                  style: TextStyle(
                    color: AppColors.fontColor,
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    labelText: user.userName,
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
                  controller: _userEmailController,
                  decoration: InputDecoration(
                    labelText: user.email,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Password',
                  style: TextStyle(
                    color: AppColors.fontColor,
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TaskButton(
                        text: 'Save',
                        onPressed: _saveData,
                        icon: Icons.save,
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
                        icon: Icons.delete,
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
                  icon: Icons.logout,
                ),
                const SizedBox(height: 15),
              ],
            ),
          );
        },
      )
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
