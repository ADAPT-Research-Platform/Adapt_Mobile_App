import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> mainNavigator = GlobalKey<NavigatorState>(debugLabel: "main");

final GlobalKey<NavigatorState> bottomNavigator = GlobalKey<NavigatorState>(debugLabel: "bottom");

final GlobalKey<NavigatorState> moduleNavigator = GlobalKey<NavigatorState>(debugLabel: "module");


final GlobalKey<ScaffoldMessengerState> loginPageScaffold = GlobalKey<ScaffoldMessengerState>(debugLabel: "login");

final GlobalKey<ScaffoldMessengerState> registerPageScaffold = GlobalKey<ScaffoldMessengerState>(debugLabel: "register");

final GlobalKey<ScaffoldMessengerState> mainPageScaffold = GlobalKey<ScaffoldMessengerState>(debugLabel: "main");