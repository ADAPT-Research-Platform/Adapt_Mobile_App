import 'package:adapt/services/auth_service.dart';
import 'package:adapt/utils/app_colors.dart';
import 'package:adapt/widgets/hexagon_grid.dart';
import 'package:flutter/material.dart';

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
  final AuthService _authService = AuthService();

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

    _authService.register(displayName, userEmail, password, passwordConfirm);
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
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppColors.darkYellow, // Static text color
                        fontSize: AppFontSizes.large, // Static font size
                        fontWeight: FontWeight.bold, // Static font weight
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Please fill your information.',
                      style: TextStyle(fontSize: AppFontSizes.small),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        labelText: 'Display Name',
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
                            value: false,
                            onChanged: (value) {
                              // Checkbox action
                              value = value;
                            }),
                        const Expanded(
                          child: Text(
                            'I agree to the data protection regulations and would like to continue to participate.',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TaskButton(
                        text: 'Register',
                        onPressed: _register
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: (){
                            mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);
                          },
                          child: const Text('Login'),
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
