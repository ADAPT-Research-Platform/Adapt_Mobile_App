import 'package:adapt/services/firebase_auth_service.dart';
import 'package:adapt/utils/app_colors.dart';
import 'package:adapt/widgets/hexagon_grid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/app_font_sizes.dart';
import '../utils/app_routes.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  @override
  void dispose(){
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userEmailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _register() async{
    String fName = _firstNameController.text.trim();
    String lName = _lastNameController.text.trim();
    String userEmail = _userEmailController.text.trim();
    String password = _passwordController.text.trim();
    String passwordConfirm = _passwordConfirmController.text.trim();

    if (password == passwordConfirm) {
      User? user = await _firebaseAuthService.signUp(fName, lName, userEmail, password);
      if(user != null){
        Navigator.of(context).pushNamed(Routes.beehiveMain);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SignUp Failed!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password doesn\'t match!')),
      );
    }
  }

  void _login() {
    Navigator.of(context).pushNamed(Routes.beehiveLogin);
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
            top: -280,
            child: HexagonGrid(
                rows: 6,
                cols: 4,
                size: 175,
                fillColor: AppColors.primaryYellow,
                strokeColor: AppColors.white,
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
                    'Sign Up',
                    style: TextStyle(
                      color: AppColors.darkYellow, // Static text color
                      fontSize: AppFontSizes.large, // Static font size
                      fontWeight: FontWeight.bold, // Static font weight
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Please fill your information.',
                    style: TextStyle(fontSize: AppFontSizes.small),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _userEmailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
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
                  SizedBox(height: 10),
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
                    onPressed: _register,
                    child: Text('Register'),
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
                      Text("Already have an account?"),
                      TextButton(
                        onPressed: _login,
                        child: Text('Login'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}