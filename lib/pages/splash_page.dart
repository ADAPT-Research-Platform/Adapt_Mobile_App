import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import '../services/CookieService.dart';
import '../services/session_manager.dart';
import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';
import '../utils/app_keys.dart';
import '../utils/app_routes.dart';
import '../widgets/hexagon_grid.dart';

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
    final size = MediaQuery.of(context).size;
    const double hexagonSize = 150;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            left: -hexagonSize / 2,
            top: -hexagonSize / 2,
            child: HexagonGrid(
              rows: (3 * screenHeight / hexagonSize).roundToDouble().toInt(),
              cols: (screenWidth / hexagonSize).roundToDouble().toInt(),
              size: hexagonSize,
              fillColor: AppColors.primaryYellow,
              strokeColor: Colors.white,
              strokeWidth: 6,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          // Centered Text
          Positioned(
            top: screenHeight / 8,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/hands_icon.png',
              width: screenWidth + 100, // Stretch to full screen width
              fit: BoxFit.fitWidth, // Maintains the aspect ratio
            ),
          ),
          Positioned(
            bottom: screenHeight / 10,
            left: 0,
            right: 0,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ADAPT',
                    style: TextStyle(
                      color: AppColors.darkYellow,
                      fontSize: AppFontSizes.massive,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Department of Psychology',
                    style: TextStyle(
                      color: AppColors.darkYellow,
                      fontSize: AppFontSizes.medium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Philipps-Universität Marburg',
                    style: TextStyle(
                      color: AppColors.darkYellow,
                      fontSize: AppFontSizes.large,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
