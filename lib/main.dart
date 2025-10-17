import 'package:adapt/pages/consent_page.dart';
import 'package:adapt/pages/splash_page.dart';
import 'package:adapt/services/localization_service.dart';
import 'package:adapt/services/notification_service.dart';
import 'package:adapt/services/session_manager.dart';
import 'package:adapt/utils/app_keys.dart';
import 'package:adapt/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../pages/login_page.dart';
import '../../pages/main_page.dart';
import '../../utils/app_routes.dart';
import 'enums/language.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure the logger
  Logger.root.level = Level.ALL; // Set the global logging level
  Logger.root.onRecord.listen((LogRecord record) {
    // Customize the log output
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Initialize Services
  await LocalizationService().init();
  await NotificationService.init();

  //Timezone Initialization
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
  //TODO: Need to Initialize Timezone Dynamically
  // final timeZoneName = await FlutterNativeTimezone.getLocalTimezone(); // get device timezone
  // tz.setLocalLocation(tz.getLocation(timeZoneName)); // set tz.local correctly

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, // Optional if you want only `portraitUp`
  ]).then((_) {
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
