import 'dart:io';

import 'package:adapt/pages/consent_page.dart';
import 'package:adapt/pages/splash_page.dart';
import 'package:adapt/services/localization_service.dart';
import 'package:adapt/services/notification_service.dart';
import 'package:adapt/utils/app_keys.dart';
import 'package:adapt/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:adapt/services/mood_service.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../pages/login_page.dart';
import '../../pages/main_page.dart';
import '../../utils/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure the logger
  Logger.root.level = Level.ALL; // Set the global logging level
  Logger.root.onRecord.listen((LogRecord record) {
    // Customize the log output
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  await NotificationService.init();
  if (await MoodService().hasMoodBeenLoggedToday()) {
    NotificationService.cancelNotification(1);
  }
  tz.initializeTimeZones();

  // Load default language (German)
  await LocalizationService().load('de');

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, // Optional if you want only `portraitUp`
  ]).then((_) {
    HttpOverrides.global = MyHttpOverrides(); // TODO: Remove this later
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // or start with ThemeMode.light/dark

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ADAPT',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode, // Switches between light and dark themes
        debugShowCheckedModeBanner: false,
        navigatorKey: mainNavigator,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case Routes.routeMain:
              return MaterialPageRoute(
                builder: (context) => MainPage(onThemeChanged: setThemeMode),
              );
            case Routes.routeLogin:
              return MaterialPageRoute(
                builder: (context) => const LoginPage(),
              );
            case Routes.routeConsent:
              return MaterialPageRoute(
                builder: (context) => ConsentPage(),
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
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
