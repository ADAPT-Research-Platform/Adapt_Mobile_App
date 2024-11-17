import 'package:adapt/services/firebase_auth_service.dart';
import 'package:adapt/utils/app_colors.dart';
import 'package:adapt/widgets/hexagon_grid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/app_font_sizes.dart';
import '../utils/app_routes.dart';
import '../utils/navigator_keys.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    _firebaseAuthService.register(displayName, userEmail, password, passwordConfirm);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        key: registerPageScaffold,
        child:  Scaffold(
          body: Stack(
            // clipBehavior: Clip.hardEdge,
            // fit: StackFit.loose,
            children: [
              Positioned.fill(
                left: -45,
                top: -MediaQuery.of(context).size.height / 4,
                child: const HexagonGrid(
                    rows: 6,
                    cols: 4,
                    size: 175,
                    fillColor: AppColors.primaryYellow,
                    strokeColor: Colors.white,
                    strokeWidth: 6),
              ),
              Positioned.fill(
                top: -MediaQuery.of(context).size.height / 1.3,
                //bottom: MediaQuery.of(context).size.height/2,
                child: Image.asset(
                  'assets/images/hands_icon.png',
                  width: MediaQuery.of(context).size.width, // Stretch to full screen width
                  fit: BoxFit.fitWidth, // Maintains the aspect ratio
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height/3.2),
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
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        labelText: 'Display Name',
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
                        Checkbox(
                            value: false,
                            onChanged: (value) {
                              // Checkbox action
                              value = value;
                            }),
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
                          onPressed: (){
                            mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);
                          },
                          child: Text('Login'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}
