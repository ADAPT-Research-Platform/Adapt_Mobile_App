import 'package:adapt/pages/splash_page.dart';
import 'package:adapt/utils/app_keys.dart';
import 'package:flutter/material.dart';

import '../../pages/login_page.dart';
import '../../pages/main_page.dart';
import '../../pages/signup_page.dart';
import '../../utils/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
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
            default:
              return MaterialPageRoute(
                builder: (context) => const SplashPage(),
              );
          }
        }
    );
  }
}
