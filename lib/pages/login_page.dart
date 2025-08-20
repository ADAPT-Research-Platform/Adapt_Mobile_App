import 'package:adapt/widgets/hexagon_grid.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../services/auth_service.dart';
import '../services/localization_service.dart';
import '../utils/app_font_sizes.dart';
import '../utils/app_keys.dart';
import '../utils/app_routes.dart';
import '../widgets/task_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final log = Logger('LoginPage');

  final AuthService _authService = AuthService();

  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isChecked = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _userEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    String userEmail = _userEmailController.text.trim();
    String password = _passwordController.text.trim();

    _authService.login(userEmail, password);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final bool isSmallScreen = screenHeight < 600; // Adjust based on your desired cutoff for small screens
    final double hexagonSize = screenWidth / 3;

    return ScaffoldMessenger(
        key: loginPageScaffold,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          // Ensures the layout adjusts when keyboard pops up
          body: Stack(
            children: [
              Positioned.fill(
                left: -hexagonSize / 2,
                top: -hexagonSize / 2,
                child: HexagonGrid(
                  rows: (1.5 * screenHeight / hexagonSize).roundToDouble().toInt(),
                  cols: (screenWidth / hexagonSize).roundToDouble().toInt(),
                  size: hexagonSize,
                  fillColor: Theme.of(context).primaryColorLight,
                  strokeColor: Theme.of(context).scaffoldBackgroundColor,
                  strokeWidth: 6,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).scaffoldBackgroundColor, Colors.transparent],
                    stops: const [0.5, 1.0],
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
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height / (isSmallScreen ? 4 : 3)),
                      Text(
                        LocalizationService().get('sign_in'),
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark, // Static text color
                          fontSize: AppFontSizes.large, // Static font size
                          fontWeight: FontWeight.bold, // Static font weight
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        LocalizationService().get('enter_your_credentials'),
                        style: const TextStyle(fontSize: AppFontSizes.small),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _userEmailController,
                        decoration: InputDecoration(
                          labelText: LocalizationService().get('username'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: LocalizationService().get('Password'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          suffixIcon: IconButton(
                            icon: _obscurePassword
                                ? Icon(Icons.visibility_off, color: Theme.of(context).primaryColorDark, size: 25)
                                : Icon(Icons.visibility, color: Theme.of(context).primaryColorDark, size: 25),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
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
                                return Theme.of(context).primaryColorDark;
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
                          text: LocalizationService().get('Login'),
                          onPressed: _isChecked ? _login : null,
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