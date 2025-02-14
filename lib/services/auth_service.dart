import 'dart:convert';

import 'package:adapt/services/session_manager.dart';
import 'package:adapt/widgets/snack_bar_shower.dart';
import 'package:logging/logging.dart';

import '../models/user.dart';
import '../utils/app_config.dart';
import '../utils/app_keys.dart';
import '../utils/app_routes.dart';

class AuthService {
  final log = Logger('AuthService');

  void login(String userNameOrEmail, String password) async {
    if(userNameOrEmail.isEmpty){
      SnackBarShower.warn(loginPageScaffold, 'Username or Email not provided!');
      return;
    }

    if(password.isEmpty){
      SnackBarShower.warn(loginPageScaffold, 'Password not provided!');
      return;
    }

    try {
      final response = await SessionManager().client.post(
            Uri.parse('${AppConfig.baseUrl}/auth/login'),
            headers: SessionManager().getHeaders(),
            body: jsonEncode({
              'username': userNameOrEmail,
              'password': password,
            }),
          );

      log.info('Login Response: ${response.body}');

      if (response.statusCode == 200) {
        // Extract the connect.sid cookie
        final cookies = response.headers['set-cookie'];
        if (cookies != null) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final sessionCookie = cookies.split(';')[0];

          User loggedIdUser = User.parse(data);
          SessionManager().setSessionInfo(
              user: loggedIdUser,
              cookie: sessionCookie
          ); // Extract the cookie value

          mainNavigator.currentState!.pushReplacementNamed(Routes.routeMain);

          // Add a short delay to wait until the next page is built
          Future.delayed(const Duration(milliseconds: 1000), () {
            SnackBarShower.info(mainPageScaffold, 'Login successful!');
          });
        } else {
          log.severe('No cookies found in Login Response.');
          SnackBarShower.error(loginPageScaffold, 'Login unsuccessful!');
        }
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        SnackBarShower.error(loginPageScaffold, jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in Login', e);
      SnackBarShower.error(loginPageScaffold, 'Internal App Error!');
    }

    return null;
  }

  void verify() async {
    final sessionCookie = await SessionManager().getSessionCookie();
    if (sessionCookie == null || sessionCookie.isEmpty) {
      log.warning('Session cookie not found!');
      mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);
      return;
    }

    final loggedIdUser = await SessionManager().getSessionUser();
    if (loggedIdUser == null) {
      log.warning('Session user not found!');
      mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);
      return;
    }

    try {
      final response = await SessionManager().client.get(
        Uri.parse('${AppConfig.baseUrl}/auth/verify-cookie'),
        headers: {
          'Cookie': sessionCookie.split('=')[1],
        },
      );

      log.info('Verify Response: ${response.body}');
      if (response.statusCode == 200) {
        log.info('Session is verified and redirecting to main page');
        mainNavigator.currentState!.pushReplacementNamed(Routes.routeMain);
        return;
      } else {
        log.warning('Session verify failed!');
      }
    } catch (e) {
      log.severe('Error verifying session: $e');
    }

    // Navigate to the login screen if not logged in or validation fails
    mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);
  }

  void logout() async {
    try {
      final response = await SessionManager().client.post(
            Uri.parse('${AppConfig.baseUrl}/auth/logout'),
            headers: SessionManager().getHeaders(),
          );

      // Navigate to the login page on any circumstances
      mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);

      log.info('Logout Response: ${response.body}');
      if (response.statusCode == 200) {
        SessionManager().clearSessionInfo();

        Future.delayed(const Duration(milliseconds: 1000), () {
          SnackBarShower.info(loginPageScaffold, 'Logout Successful!');
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          SnackBarShower.error(loginPageScaffold, jsonResponse['message']);
        });
      }
    } catch (e) {
      log.severe('Error in Logout', e);
      Future.delayed(const Duration(milliseconds: 1000), () {
        SnackBarShower.error(loginPageScaffold, 'Internal App Error!');
      });
    }
  }

  void track(DateTime? sessionStart, DateTime? sessionEnd) async{
    if(sessionStart == null){
      log.warning("Start time is null");
      return;
    }

    try {
      final response = await SessionManager().client.post(
        Uri.parse('${AppConfig.baseUrl}/tracks'),
        headers: SessionManager().getHeaders(),
        body: jsonEncode({
          'startedAt': sessionStart.toIso8601String(),
          'endedAt': (sessionEnd != null) ? sessionEnd.toIso8601String() : "",
        }),
      );

      log.info('Track Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        log.info('Tracking Data updated');
      } else {
        log.warning('Tracking Data update failed');
      }
    } catch (e) {
      log.severe('Error in Tracking Data update', e);
    }

    return null;
  }
}
