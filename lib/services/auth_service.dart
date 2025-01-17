import 'dart:convert';

import 'package:adapt/services/session_manager.dart';
import 'package:adapt/widgets/snack_bar_shower.dart';

import '../models/user.dart';
import '../utils/app_config.dart';
import '../utils/app_keys.dart';
import '../utils/app_routes.dart';
import 'CookieService.dart';

class AuthService {
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
          final Map<String, dynamic> data = jsonDecode(response.body);
          final sessionCookie = cookies.split(';')[0];

          User loggedIdUser = User.parse(data);
          SessionManager().setSessionInfo(
              user: loggedIdUser,
              cookie: sessionCookie
          ); // Extract the cookie value
          await CookieService().saveCookie(sessionCookie);
          await CookieService().saveUser(loggedIdUser);

          mainNavigator.currentState!.pushReplacementNamed(Routes.routeMain);

          // Add a short delay to wait until the next page is built
          Future.delayed(const Duration(milliseconds: 1000), () {
            SnackBarShower.info(mainPageScaffold, 'Login successful');
          });
        } else {
          print('No cookies found in the response.');
        }
      } else {
        print('Login failed: ${response.statusCode}: ${response.body}');
        SnackBarShower.info(loginPageScaffold, 'Login successful');
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
        SnackBarShower.info(loginPageScaffold, 'Log out successful');
      });
    }
  }
}
