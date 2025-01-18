import 'package:adapt/services/user_service.dart';
import 'package:adapt/utils/app_colors.dart';
import 'package:adapt/widgets/hexagon_grid.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

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
    final bool isSmallScreen =
        size.height < 600; // Adjust cutoff for small screens

    return ScaffoldMessenger(
      key: signupPageScaffold,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              const Positioned.fill(
                left: -45,
                top: -160,
                child: HexagonGrid(
                  rows: 6,
                  cols: 4,
                  size: 175,
                  fillColor: AppColors.primaryYellow,
                  strokeColor: Colors.white,
                  strokeWidth: 6,
                ),
              ),
              Positioned.fill(
                top: -size.height / 1.5,
                child: Image.asset(
                  'assets/images/hands_icon.png',
                  width: size.width + 100, // Stretch to full screen width
                  fit: BoxFit.fitWidth, // Maintains the aspect ratio
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height / (isSmallScreen ? 4 : 3)),
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppColors.darkYellow,
                        fontSize: AppFontSizes.large,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Please fill your information.',
                      style: TextStyle(fontSize: AppFontSizes.small),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        labelText: 'User Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _userEmailController,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
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
                        labelText: 'Password',
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
                        labelText: 'Confirm Password',
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
                              text: 'I agree to the data protection regulations and would like to continue to participate. ',
                              children: [
                                TextSpan(
                                  text: 'Here.',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      mainNavigator.currentState!.pushNamed(Routes.routeConsent);
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
                      text: 'Register',
                      onPressed: _isChecked ? _register : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
