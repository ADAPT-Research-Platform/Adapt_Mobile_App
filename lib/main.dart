import 'dart:io';

import 'package:adapt/pages/consent_page.dart';
import 'package:adapt/pages/overview_page.dart';
import 'package:adapt/pages/splash_page.dart';
import 'package:adapt/services/notification_service.dart';
import 'package:adapt/utils/app_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../pages/login_page.dart';
import '../../pages/main_page.dart';
import '../../pages/signup_page.dart';
import '../../utils/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  tz.initializeTimeZones();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, // Optional if you want only `portraitUp`
  ]).then((_) {
    HttpOverrides.global = MyHttpOverrides(); // TODO: Remove this later
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ADAPT',
        debugShowCheckedModeBanner: false,
        navigatorKey: mainNavigator,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case Routes.routeMain:
              return MaterialPageRoute(
                builder: (context) => const MainPage(),
              );
            case Routes.routeLogin:
              return MaterialPageRoute(
                builder: (context) => const LoginPage(),
              );
            case Routes.routeSignUp:
              return MaterialPageRoute(
                builder: (context) => const SignUpPage(),
              );
            case Routes.routeConsent:
              return MaterialPageRoute(
                builder: (context) => const ConsentPage(),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => const SplashPage(),
              );
          }
        });
  }
}

// TODO: This is only for testing purposes. Need Remove this
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
