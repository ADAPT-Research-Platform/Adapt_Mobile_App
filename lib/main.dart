import 'package:adapt/pages/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:adapt/utils/navigator_keys.dart';
import '../../utils/app_routes.dart';
import '../../pages/login_page.dart';
import '../../pages/main_page.dart';
import '../../pages/signup_page.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        navigatorKey: globalNavigatorKey,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case Routes.beehiveMain:
              return MaterialPageRoute(
                builder: (context) => const MainPage(),
              );
            case Routes.beehiveLogin:
              return MaterialPageRoute(
                builder: (context) => const LoginPage(),
              );
            case Routes.beehiveSignUp:
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
