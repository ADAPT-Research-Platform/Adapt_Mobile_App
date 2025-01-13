import 'package:adapt/services/session_manager.dart';
import 'package:adapt/utils/app_colors.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../utils/app_config.dart';
import '../utils/app_routes.dart';
import '../utils/app_keys.dart';
import 'dart:convert';

class AuthService {
  void register(String userName, String email, String password, String passwordConfirm) async {
    final url = '${AppConfig.baseUrl}/api/users';

    // Validate passwords
    if (password != passwordConfirm) {
      print('Passwords do not match.');
      return;
    }

    try {
      final response = await SessionManager().client.post(
        Uri.parse(url),
        headers: SessionManager().getHeaders(),
        body: jsonEncode({
          'username': userName,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        print('Registration successful!');

        mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);

        // Add a short delay to wait until the next page is built
        Future.delayed(const Duration(milliseconds: 1000), () {
          _showSnackBar(
              loginPageScaffold, 'Registration Successful. Please Login!');
        });
      } else if (response.statusCode == 400) {
        print('Bad Request: ${response.body}');
        // Handle validation errors from the server response
      } else {
        print('Registration failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error during registration: $e');
    }
  }

  void login(String email, String password) async {
    const url = '${AppConfig.baseUrl}/api/auth/login';

    try {
      final response = await SessionManager().client.post(
        Uri.parse(url),
        headers: SessionManager().getHeaders(),
        body: jsonEncode({
          'login': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Extract the connect.sid cookie
        final cookies = response.headers['set-cookie'];
        if (cookies != null) {
          final dynamic data = jsonDecode(response.body);
          SessionManager().setSessionInfo(user: parseUser(data), cookie: cookies.split(';')[0]); // Extract the cookie value

          mainNavigator.currentState!.pushReplacementNamed(Routes.routeMain);

          // Add a short delay to wait until the next page is built
          Future.delayed(const Duration(milliseconds: 1000), () {
            _showSnackBar(mainPageScaffold, 'Login successful');
          });
        } else {
          print('No cookies found in the response.');
        }
      } else {
        print('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during login: $e');
    }

    return null;
  }

  void logout() async {
    const url = '${AppConfig.baseUrl}/api/auth/logout';

    final response = await SessionManager().client.post(
      Uri.parse(url),
      headers: SessionManager().getHeaders(),
    );

    // Navigate to the login page on any circumstances
    mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);

    if (response.statusCode == 200) {
      SessionManager().clearSessionInfo();

      // Add a short delay to wait until the next page is built
      Future.delayed(const Duration(milliseconds: 1000), () {
        _showSnackBar(loginPageScaffold, 'Log out successful');
      });
    }
  }

  User parseUser(Map<String, dynamic> json) {
    return User(
      userId: json['id'].toString(),
      userName: json['username'].toString(),
      email: json['email'].toString(),
    );
  }

  //Show particular message
  void _showSnackBar(GlobalKey<ScaffoldMessengerState> scaffold, String message) {
    print(message);
    // Show a success message
    if (scaffold.currentState != null) {
      scaffold.currentState!.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.darkYellow),
      );
    }
  }
}
