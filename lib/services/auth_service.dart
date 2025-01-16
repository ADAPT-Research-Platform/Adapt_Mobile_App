import 'dart:convert';

import 'package:adapt/services/session_manager.dart';
import 'package:adapt/utils/app_colors.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../utils/app_config.dart';
import '../utils/app_keys.dart';
import '../utils/app_routes.dart';
import 'CookieService.dart';

class AuthService {
  void register(String userName, String email, String password, String passwordConfirm) async {
    // Validate passwords
    if (password != passwordConfirm) {
      print('Passwords do not match.');
      return;
    }

    try {
      final response = await SessionManager().client.post(
            Uri.parse('${AppConfig.baseUrl}/users'),
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
    try {
      final response = await SessionManager().client.post(
            Uri.parse('${AppConfig.baseUrl}/auth/login'),
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
          final sessionCookie = cookies.split(';')[0];
          SessionManager().setSessionInfo(
              user: parseUser(data),
              cookie: sessionCookie); // Extract the cookie value
          await CookieService().saveCookie(sessionCookie);
          await CookieService().saveUser(parseUser(data));

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
    final response = await SessionManager().client.post(
          Uri.parse('${AppConfig.baseUrl}/auth/logout'),
          headers: SessionManager().getHeaders(),
        );

    // Navigate to the login page on any circumstances
    mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);

    if (response.statusCode == 200) {
      SessionManager().clearSessionInfo();
      await CookieService().deleteCookie();

      // Add a short delay to wait until the next page is built
      Future.delayed(const Duration(milliseconds: 1000), () {
        _showSnackBar(loginPageScaffold, 'Log out successful');
      });
    }
  }

  // Call the get user API
  Future<User?> getUser() async {
    try {
      final response = await SessionManager().client.get(
        Uri.parse('${AppConfig.baseUrl}/users/me'),
        headers: SessionManager().getHeaders(),
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        return parseUser(data);
      } else {
        print('Failed to fetch user: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during fetching user: $e');
      return null;
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
  void _showSnackBar(
      GlobalKey<ScaffoldMessengerState> scaffold, String message) {
    print(message);
    // Show a success message
    if (scaffold.currentState != null) {
      scaffold.currentState!.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.darkYellow),
      );
    }
  }
}
