import 'package:adapt/widgets/hexagon_grid.dart';
import 'package:flutter/material.dart';

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
  final AuthService _authService = AuthService();

  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose(){
    _userEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async{
    String userEmail = _userEmailController.text.trim();
    String password = _passwordController.text.trim();

    _authService.login(userEmail, password);
  }

  //TODO: Temporary Method Just to ByPass login
  void _login_bypass() async{
    String userEmail = "risithmarshall@gmail.com";
    String password = "apple123";

    _authService.login(userEmail, password);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.height < 600; // Adjust based on your desired cutoff for small screens

    return ScaffoldMessenger(
        key: loginPageScaffold,
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
                        'Login',
                        style: TextStyle(
                          color: AppColors.darkYellow, // Static text color
                          fontSize: AppFontSizes.large, // Static font size
                          fontWeight: FontWeight.bold, // Static font weight
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Please login to your account.',
                        style: TextStyle(fontSize: AppFontSizes.small),
                      ),
                      const SizedBox(height: 20),
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(value: false, onChanged: (value) {}),
                          const Expanded(
                            child: Text(
                              'I agree to the data protection regulations and would like to continue to participate.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TaskButton(
                          text: 'Login',
                          onPressed: _login
                      ),
                      const SizedBox(height: 10),
                      TaskButton(
                          text: 'Login ByPass',
                          onPressed: _login_bypass
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? "),
                          TextButton(
                            onPressed: (){
                              mainNavigator.currentState!.pushReplacementNamed(Routes.routeSignUp);
                            },
                            child: Text('Register'),
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
        )
      );
  }
}