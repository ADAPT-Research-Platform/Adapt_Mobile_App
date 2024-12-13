import 'package:adapt/widgets/app_title_bar.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/firebase_auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});


  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

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
    _loggedInUser = _firebaseAuthService.getLoggedInUser(); // Initialize the Future
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
      appBar: const AppTitleBar(title: 'Settings'),
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
                    labelText: user.userCode.toString(),
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
                    labelText: user.displayName,
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
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: user.role,
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
                        onPressed: _saveData,
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
                    _firebaseAuthService.logout();
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
