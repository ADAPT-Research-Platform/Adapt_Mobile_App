import 'package:adapt/widgets/hexagon_grid.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../services/auth_service.dart';
import '../utils/app_colors.dart';
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
    const double hexagonSize = 150;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final bool isSmallScreen = screenHeight < 600; // Adjust based on your desired cutoff for small screens

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
                  fillColor: AppColors.primaryYellow,
                  strokeColor: Colors.white,
                  strokeWidth: 6,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.transparent],
                    stops: [0.5, 1.0],
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
                      const Text(
                        'Login',
                        style: TextStyle(
                          color: AppColors.darkYellow, // Static text color
                          fontSize: AppFontSizes.large, // Static font size
                          fontWeight: FontWeight.bold, // Static font weight
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Please enter your credentials',
                        style: TextStyle(fontSize: AppFontSizes.small),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _userEmailController,
                        decoration: InputDecoration(
                          labelText: 'Username or Email',
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TaskButton(
                          text: 'Login',
                          onPressed: _login
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          TextButton(
                            onPressed: () {
                              mainNavigator.currentState!.pushReplacementNamed(Routes.routeSignUp);
                            },
                            child: const Text('Register'),
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