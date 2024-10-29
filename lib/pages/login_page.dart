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
      globalNavigatorKey.currentState!.pushNamed(Routes.beehiveMain);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Unsuccessfull!')),
      );
    }
  }

  //Temporary Method Just to ByPass login
  void _login_bypass() async{
    print("Login Successfull");
    globalNavigatorKey.currentState!.pushNamed(Routes.beehiveMain);
  }

  void _register() {
    globalNavigatorKey.currentState!.pushNamed(Routes.beehiveSignUp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        // clipBehavior: Clip.hardEdge,
        // fit: StackFit.loose,
        children: [
           Positioned.fill(
            left: -45,
            top: -180,
            child: HexagonGrid(
              rows: 6,
              cols: 4,
              size: 175,
              fillColor: AppColors.primaryYellow,
              strokeColor: Colors.white,
              strokeWidth: 6
            ),
          ),
         Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/hands_icon.png',
                    height: 100,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Login',
                    style: TextStyle(
                      color: AppColors.darkYellow, // Static text color
                      fontSize: AppFontSizes.large, // Static font size
                      fontWeight: FontWeight.bold, // Static font weight
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
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
                  SizedBox(height: 20),
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
                  SizedBox(height: 10),
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
          ),
        ],
      ),
    );
  }
}