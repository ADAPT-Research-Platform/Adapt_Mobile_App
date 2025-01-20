import 'package:adapt/services/user_service.dart';
import 'package:adapt/utils/app_colors.dart';
import 'package:adapt/widgets/hexagon_grid.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../services/localization_service.dart';
import '../utils/app_font_sizes.dart';
import '../utils/app_keys.dart';
import '../utils/app_routes.dart';
import '../widgets/task_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final log = Logger('SignUpPage');

  final UserService _userService = UserService();
  bool _isChecked = false;

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    _userEmailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _register() async {
    String displayName = _displayNameController.text.trim();
    String userEmail = _userEmailController.text.trim();
    String password = _passwordController.text.trim();
    String passwordConfirm = _passwordConfirmController.text.trim();

    _userService.addUser(displayName, userEmail, password, passwordConfirm);
  }

  @override
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double hexagonSize = 150;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final bool isSmallScreen = screenHeight < 600; // Adjust based on your desired cutoff for small screens

    return ScaffoldMessenger(
        key: signupPageScaffold,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          // Ensures the layout adjusts when keyboard pops up
          body: Stack(
            children: [
              Positioned.fill(
                left: -hexagonSize / 2,
                top: -hexagonSize / 2,
                child: HexagonGrid(
                  rows: (screenHeight / hexagonSize).roundToDouble().toInt(),
                  cols: (screenWidth / hexagonSize).roundToDouble().toInt(),
                  size: hexagonSize,
                  fillColor: AppColors.primaryYellow,
                  strokeColor: Colors.white,
                  strokeWidth: 6,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.transparent],
                    stops: [0.6, 1.0],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              // Centered Text
              Positioned.fill(
                top: -screenHeight / 1.5,
                child: Image.asset(
                  'assets/images/hands_icon.png',
                  width: screenWidth + 100, // Stretch to full screen width
                  fit: BoxFit.fitWidth, // Maintains the aspect ratio
                ),
              ),
              // Scrollable content
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height / (isSmallScreen ? 4 : 3)),
                      Text(
                        LocalizationService().get('sign_up'),
                        style: const TextStyle(
                          color: AppColors.darkYellow,
                          fontSize: AppFontSizes.large,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                       Text(
                        LocalizationService().get('fill_your_information'),
                        style: const TextStyle(fontSize: AppFontSizes.small),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _displayNameController,
                        decoration: InputDecoration(
                          labelText: LocalizationService().get('user_name'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _userEmailController,
                        decoration: InputDecoration(
                          labelText: LocalizationService().get('email_address'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: LocalizationService().get('Password'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordConfirmController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: LocalizationService().get('confirm_password'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: _isChecked,
                            fillColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return AppColors.darkYellow;
                              }
                              return null;
                            }),
                            onChanged: (value) {
                              setState(() {
                                _isChecked = value!;
                              });
                            },
                          ),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: LocalizationService().get('regulation'),
                                children: [
                                  TextSpan(
                                    text: 'Here.',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        mainNavigator.currentState!
                                            .pushNamed(Routes.routeConsent);
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TaskButton(
                        text: LocalizationService().get('Register'),
                        onPressed: _isChecked ? _register : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(LocalizationService().get('already_have_an_account')),
                          TextButton(
                            onPressed: () {
                              mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);
                            },
                            child: Text(LocalizationService().get('Login')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}
