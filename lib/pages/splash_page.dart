import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import '../services/CookieService.dart';
import '../services/session_manager.dart';
import '../utils/app_keys.dart';
import '../utils/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  final log = Logger('SplashPage');

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _checkLoginStatus();
  }

  /// Check login status and navigate accordingly
  Future<void> _checkLoginStatus() async {
    // Retrieve cookie and user simultaneously for efficiency
    final cookieFuture = CookieService().getCookie();
    final userFuture = CookieService().getUser();

    // Delay for splash screen visibility
    await Future.delayed(const Duration(seconds: 2));

    final cookie = await cookieFuture;
    final user = await userFuture;

    // Check if both cookie and user are present
    if (cookie != null && cookie.isNotEmpty && user != null) {
      // Validate the cookie with the backend
      final isValid = await CookieService().verifyCookieWithBackend();

      if (isValid) {
        // Set cookie and user details in session manager
        SessionManager().setSessionInfo(cookie: cookie, user: user);
        mainNavigator.currentState!.pushReplacementNamed(Routes.routeMain);
        return;
      }
    }

    // Navigate to the login screen if not logged in or validation fails
    mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Image(
          image: AssetImage('assets/images/splash_screen.png'),
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
