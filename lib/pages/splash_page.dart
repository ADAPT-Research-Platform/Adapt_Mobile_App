import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/CookieService.dart';
import '../services/session_manager.dart';
import '../utils/app_keys.dart';
import '../utils/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _checkLoginStatus();
  }

  /// Check login status and navigate accordingly
  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await CookieService().hasCookie();
    final user = await CookieService().getUser();

    // Delay for splash screen visibility
    await Future.delayed(const Duration(seconds: 2));

    // Navigate to the appropriate page
    if (isLoggedIn && user != null) {
      // Set cookie value to session manager
      SessionManager()
          .setSessionInfo(cookie: await CookieService().getCookie(), user: user);
      mainNavigator.currentState!.pushReplacementNamed(Routes.routeMain);
    } else {
      mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);
    }
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
