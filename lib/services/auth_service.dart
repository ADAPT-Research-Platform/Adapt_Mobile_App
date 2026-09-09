import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adapt/services/session_manager.dart';
import 'package:adapt/widgets/snack_bar_shower.dart';
import 'package:logging/logging.dart';

import '../models/user.dart';
import '../utils/app_config.dart';
import '../utils/app_keys.dart';
import '../utils/app_routes.dart';

class AuthService {
  final log = Logger('AuthService');

  Future<bool> login(String userName, String password) async {
    if (userName.isEmpty) {
      SnackBarShower.warn(loginPageScaffold, 'username_missing');
      return false;
    }

    if (password.isEmpty) {
      SnackBarShower.warn(loginPageScaffold, 'password_missing');
      return false;
    }

    final loginUri = Uri.parse('${AppConfig.baseUrl}/auth/login');
    log.info('Initiating login request to $loginUri for user: $userName');

    try {
      final response = await SessionManager().client.post(
            loginUri,
            headers: SessionManager().getHeaders(),
            body: jsonEncode({
              'username': userName,
              'password': password,
            }),
          ).timeout(const Duration(seconds: 15));

      log.info('Login Response Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        // Extract session cookie (specifically connect.sid or first valid cookie)
        final setCookieHeader = response.headers['set-cookie'];
        log.info('Received Set-Cookie header: $setCookieHeader');

        String? sessionCookie;
        if (setCookieHeader != null) {
          final match = RegExp(r'(connect\.sid=[^;,]+)').firstMatch(setCookieHeader);
          if (match != null) {
            sessionCookie = match.group(1);
          } else {
            sessionCookie = setCookieHeader.split(';')[0].trim();
          }
        }

        if (sessionCookie != null && sessionCookie.isNotEmpty) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          User loggedIdUser = User.parse(data);

          log.info('Login successful. Storing session for user: ${loggedIdUser.userName}, cookie: $sessionCookie');
          await SessionManager().setSessionInfo(
            user: loggedIdUser,
            cookie: sessionCookie,
          );

          mainNavigator.currentState!.pushReplacementNamed(Routes.routeMain);

          Future.delayed(const Duration(milliseconds: 500), () {
            SnackBarShower.info(mainPageScaffold, 'login_success');
          });
          return true;
        } else {
          log.severe('No valid session cookie found in Set-Cookie: $setCookieHeader');
          SnackBarShower.error(loginPageScaffold, 'login_failure');
          return false;
        }
      } else {
        log.warning('Login failed with status ${response.statusCode}: ${response.body}');
        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          final message = jsonResponse['message'] ?? 'login_failure';
          SnackBarShower.error(loginPageScaffold, message);
        } catch (_) {
          SnackBarShower.error(loginPageScaffold, 'login_failure');
        }
        return false;
      }
    } on TimeoutException catch (e) {
      log.severe('Login timed out after 15 seconds: $e', e);
      SnackBarShower.error(loginPageScaffold, 'login_failure');
      return false;
    } on SocketException catch (e) {
      log.severe('Network error during login (SocketException): $e', e);
      SnackBarShower.error(loginPageScaffold, 'login_failure');
      return false;
    } on HandshakeException catch (e) {
      log.severe('TLS/SSL handshake error during login: $e', e);
      SnackBarShower.error(loginPageScaffold, 'login_failure');
      return false;
    } catch (e, stackTrace) {
      log.severe('Unexpected error during login: $e', e, stackTrace);
      SnackBarShower.error(loginPageScaffold, 'internal_app_error');
      return false;
    }
  }

  Future<bool> verify() async {
    final sessionCookie = await SessionManager().getSessionCookie();
    if (sessionCookie == null || sessionCookie.isEmpty) {
      log.warning('Session cookie not found in storage. Redirecting to login.');
      mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);
      return false;
    }

    final loggedIdUser = await SessionManager().getSessionUser();
    if (loggedIdUser == null) {
      log.warning('Session user not found in storage. Redirecting to login.');
      mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);
      return false;
    }

    final verifyUri = Uri.parse('${AppConfig.baseUrl}/auth/verify-cookie');
    log.info('Verifying session at $verifyUri with cookie: $sessionCookie');

    try {
      final response = await SessionManager().client.get(
        verifyUri,
        headers: SessionManager().getHeaders(),
      ).timeout(const Duration(seconds: 15));

      log.info('Verify Response Status: ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 200) {
        log.info('Session verified successfully. Redirecting to main page.');
        mainNavigator.currentState!.pushReplacementNamed(Routes.routeMain);
        return true;
      } else {
        log.warning('Session verify returned status: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      log.severe('Verify session timed out: $e', e);
    } on SocketException catch (e) {
      log.severe('Verify session network error: $e', e);
    } catch (e, stackTrace) {
      log.severe('Error verifying session: $e', e, stackTrace);
    }

    log.info('Session validation failed. Redirecting to login screen.');
    mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);
    return false;
  }

  Future<void> logout() async {
    try {
      final response = await SessionManager().client.post(
            Uri.parse('${AppConfig.baseUrl}/auth/logout'),
            headers: SessionManager().getHeaders(),
          ).timeout(const Duration(seconds: 10));

      mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);

      log.info('Logout Response: ${response.body}');
      if (response.statusCode == 200) {
        await SessionManager().clearSessionInfo();

        Future.delayed(const Duration(milliseconds: 1000), () {
          SnackBarShower.info(loginPageScaffold, 'logout_success');
        });
      } else {
        await SessionManager().clearSessionInfo();
        Future.delayed(const Duration(milliseconds: 1000), () {
          try {
            final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
            SnackBarShower.error(loginPageScaffold, jsonResponse['message'] ?? 'internal_app_error');
          } catch (_) {
            SnackBarShower.error(loginPageScaffold, 'internal_app_error');
          }
        });
      }
    } catch (e, stackTrace) {
      log.severe('Error in Logout: $e', e, stackTrace);
      await SessionManager().clearSessionInfo();
      mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);
      Future.delayed(const Duration(milliseconds: 1000), () {
        SnackBarShower.error(loginPageScaffold, 'internal_app_error');
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
