import 'dart:convert';

import 'package:adapt/services/session_manager.dart';
import 'package:logging/logging.dart';

import '../utils/app_config.dart';
import '../utils/app_keys.dart';
import '../utils/app_routes.dart';
import '../widgets/snack_bar_shower.dart';
import 'CookieService.dart';

class UserService {
  final log = Logger('UserService');

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

      log.info('User Add Response: ${response.body}');
      if (response.statusCode == 201) {
        mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);

        Future.delayed(const Duration(milliseconds: 1000), () {
          SnackBarShower.info(loginPageScaffold, 'Signup Successful! Verify Email.');
        });
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        SnackBarShower.error(signupPageScaffold, jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in User Adding', e);
      SnackBarShower.error(signupPageScaffold, 'Internal App Error!');
    }
  }

  void updateUser(String userName, String currentPassword, String newPassword, String confirmNewPassword) async {
    if(userName.isEmpty){
      SnackBarShower.warn(mainPageScaffold, 'User name cannot be empty!');
      return;
    }

    if(userName == SessionManager().sessionUser!.userName && newPassword.isEmpty){
      SnackBarShower.warn(mainPageScaffold, 'Nothing to update!');
      return;
    }

    if(newPassword.isNotEmpty){ //Which means user has given a new password

      if(currentPassword.isEmpty){
        SnackBarShower.warn(mainPageScaffold, 'Current password should be provided!');
        return;
      }

      // Validate passwords
      if (newPassword != confirmNewPassword) {
        SnackBarShower.warn(mainPageScaffold, 'Confirm New Passwords don\'t match!');
        return;
      }
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

      log.info('User Update Response: ${response.body}');
      if (response.statusCode == 200) {
        SessionManager().sessionUser?.userName = userName;
        SnackBarShower.info(mainPageScaffold, 'User Update Successful!');
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        SnackBarShower.error(mainPageScaffold, jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in User Update', e);
      SnackBarShower.error(mainPageScaffold, 'Internal App Error!');
    }
  }

  void deleteUser(String currentPassword) async {
    if(currentPassword.isEmpty){
      SnackBarShower.warn(signupPageScaffold, 'Password not provided!');
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

      log.info('User Delete Response: ${response.body}');
      if (response.statusCode == 200) {
        SessionManager().clearSessionInfo();
        await CookieService().deleteCookie();

        Future.delayed(const Duration(milliseconds: 1000), () {
          SnackBarShower.info(loginPageScaffold, 'User Delete Successful!');
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          SnackBarShower.error(loginPageScaffold, jsonResponse['message']);
        });
      }
    } catch (e) {
      log.severe('Error in User Delete', e);
      Future.delayed(const Duration(milliseconds: 1000), () {
        SnackBarShower.error(loginPageScaffold, 'Internal App Error!');
      });
    }
  }
}
