import 'dart:convert';

import 'package:adapt/services/auth_service.dart';
import 'package:adapt/services/session_manager.dart';

import '../utils/app_config.dart';
import '../utils/app_keys.dart';
import '../utils/app_routes.dart';
import '../widgets/snack_bar_shower.dart';
import 'CookieService.dart';

class UserService {
  void addUser(String userName, String email, String password, String passwordConfirm) async {

    if(userName.isEmpty){
      SnackBarShower.warn(signupPageScaffold, 'User name cannot be empty!');
      return;
    }

    if(email.isEmpty){
      SnackBarShower.warn(signupPageScaffold, 'Email cannot be empty!');
      return;
    }

    if(password.isEmpty){
      SnackBarShower.warn(signupPageScaffold, 'Password cannot be empty!');
      return;
    }

    // Validate passwords
    if (password != passwordConfirm) {
      SnackBarShower.warn(signupPageScaffold, 'Passwords don\'t match!');
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
        mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);

        // Add a short delay to wait until the next page is built
        Future.delayed(const Duration(milliseconds: 1000), () {
          SnackBarShower.info(loginPageScaffold, 'Registration Successful. Please Login!');
        });
      } else if (response.statusCode == 400) {
        print('Bad Request: ${response.body}');
        // Handle validation errors from the server response
      } else {
        SnackBarShower.error(loginPageScaffold, 'Signup Failed! ${response.body}');
      }
    } catch (e) {
      print('Error during registration: $e');
    }
  }

  void updateUser(String userName, String currentPassword, String newPassword) async {
    if(currentPassword.isEmpty){
      SnackBarShower.warn(signupPageScaffold, 'Current password cannot be empty!');
      return;
    }

    if(userName.isEmpty){
      SnackBarShower.warn(signupPageScaffold, 'User name cannot be empty!');
      return;
    }

    if(userName == SessionManager().sessionUser!.userName && newPassword.isEmpty){
      SnackBarShower.warn(signupPageScaffold, 'Nothing to update!');
      return;
    }

    try {
      final response = await SessionManager().client.put(
        Uri.parse('${AppConfig.baseUrl}/users'),
        headers: SessionManager().getHeaders(),
        body: jsonEncode({
          'userName': userName,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        SnackBarShower.info(mainPageScaffold, 'User Update Successful!');
      } else {
        print('User Update Failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error during registration: $e');
    }
  }

  void deleteUser(String currentPassword) async {
    if(currentPassword.isEmpty){
      SnackBarShower.warn(signupPageScaffold, 'Current password cannot be empty!');
      return;
    }

    try {
      final response = await SessionManager().client.delete(
        Uri.parse('${AppConfig.baseUrl}/users'),
        headers: SessionManager().getHeaders(),
        body: jsonEncode({
          'currentPassword': currentPassword,
        }),
      );

      // Navigate to the login page on any circumstances
      mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);

      if (response.statusCode == 200) {
        SessionManager().clearSessionInfo();
        await CookieService().deleteCookie();

        // Add a short delay to wait until the next page is built
        Future.delayed(const Duration(milliseconds: 1000), () {
          SnackBarShower.info(loginPageScaffold, 'User delete successful!');
        });
      } else {
        print('Registration failed: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error during registration: $e');
    }
  }
}
