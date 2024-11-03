import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_routes.dart';
import '../utils/navigator_keys.dart';

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

    Future.delayed(const Duration(seconds: 2), () {
      mainNavigator.currentState!.pushNamed(Routes.routeLogin);
    });
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
