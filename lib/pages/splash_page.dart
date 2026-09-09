import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import '../services/auth_service.dart';
import '../services/localization_service.dart';
import '../utils/app_font_sizes.dart';
import '../widgets/hexagon_grid.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  final log = Logger('SplashPage');

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Delay for splash screen visibility
    await Future.delayed(const Duration(seconds: 2));
    await _authService.verify();
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
    final screenWidth = size.width;
    final screenHeight = size.height;
    final double hexagonSize = screenWidth / 3;

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
              fillColor: Theme.of(context).primaryColorLight,
              strokeColor: Theme.of(context).scaffoldBackgroundColor,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown, // Scales down the content to fit
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ADAPT',
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: AppFontSizes.massive,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        LocalizationService().get('department'),
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: AppFontSizes.medium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        LocalizationService().get('university'),
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: AppFontSizes.large,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
