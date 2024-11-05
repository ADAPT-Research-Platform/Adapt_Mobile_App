import 'package:adapt/widgets/hexagon_grid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firebase_auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';
import '../utils/app_routes.dart';
import '../utils/navigator_keys.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

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

    User? user = await _firebaseAuthService.signIn(userEmail, password);
    if(user != null){
      print("Login Successfull");
      mainNavigator.currentState!.pushNamed(Routes.routeMain);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Unsuccessfull!')),
      );
    }
  }

  //Temporary Method Just to ByPass login
  void _login_bypass() async{
    print("Login Successfull");
    mainNavigator.currentState!.pushNamed(Routes.routeMain);
  }

  void _register() {
    mainNavigator.currentState!.pushNamed(Routes.routeSignUp);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.height < 600; // Adjust based on your desired cutoff for small screens

    return Scaffold(
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
                  SizedBox(height: 20),
                  const Text(
                    'Please login to your account.',
                    style: TextStyle(fontSize: AppFontSizes.small),
                  ),
                  SizedBox(height: 20),
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
                      child: Text('Forgot Password?'),
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (value) {}),
                      Expanded(
                        child: Text(
                          'I agree to the data protection regulations and would like to continue to participate.',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      backgroundColor: AppColors.primaryYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _login_bypass,
                    child: Text('Login ByPass'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      backgroundColor: AppColors.primaryYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? "),
                      TextButton(
                        onPressed: _register,
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
    );
  }
}