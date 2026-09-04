import 'package:flutter/material.dart';

//Navigation State Keys
final GlobalKey<NavigatorState> mainNavigator = GlobalKey<NavigatorState>(debugLabel: "main");

final GlobalKey<NavigatorState> bottomNavigator = GlobalKey<NavigatorState>(debugLabel: "bottom");

final GlobalKey<NavigatorState> moduleNavigator = GlobalKey<NavigatorState>(debugLabel: "module");

//Scaffold State Keys
final GlobalKey<ScaffoldMessengerState> loginPageScaffold = GlobalKey<ScaffoldMessengerState>(debugLabel: "login");

final GlobalKey<ScaffoldMessengerState> signupPageScaffold = GlobalKey<ScaffoldMessengerState>(debugLabel: "register");

final GlobalKey<ScaffoldMessengerState> mainPageScaffold = GlobalKey<ScaffoldMessengerState>(debugLabel: "main");

final GlobalKey<ScaffoldMessengerState> settingPageScaffold = GlobalKey<ScaffoldMessengerState>(debugLabel: "setting");