import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'login_screen.dart';
import 'size_config.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _errorMessage = '';

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final safeAreaSize = getSafeAreaSize(mediaQueryData);

    return Scaffold(
      backgroundColor: AppColors.lightYellow,
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: AppColors.primaryYellow,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getDeviceExactWidth(24.0, safeAreaSize),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: getDeviceExactHeight(100.0, safeAreaSize)),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  fillColor: AppColors.white,
                  filled: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _email = value,
                validator: (value) => value!.isEmpty ? 'Enter an email' : null,
              ),
              SizedBox(height: getDeviceExactHeight(20.0, safeAreaSize)),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  fillColor: AppColors.white,
                  filled: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _password = value,
                validator: (value) => value!.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
                obscureText: true,
              ),
              SizedBox(height: getDeviceExactHeight(50.0, safeAreaSize)),
              ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkYellow,
                  padding: EdgeInsets.symmetric(
                    vertical: getDeviceExactHeight(15.0, safeAreaSize),
                    horizontal: getDeviceExactWidth(120.0, safeAreaSize),
                  ),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(
                      top: getDeviceExactHeight(20.0, safeAreaSize)),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: getDeviceExactHeight(20.0, safeAreaSize)),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(
                  'Already have an account? Login here',
                  style: TextStyle(
                    color: AppColors.darkYellow,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
