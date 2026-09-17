import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adapt/pages/overview_page.dart';
import 'package:adapt/pages/module_index_page.dart';
import 'package:adapt/pages/main_page.dart';
import 'package:adapt/services/localization_service.dart';
import 'package:adapt/enums/language.dart';
import 'package:adapt/utils/app_keys.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
  });

  group('3-Tier Navigation and Back Press Tests', () {
    late bool didCallSystemNavigatorPop;
    const MethodChannel notificationChannel =
        MethodChannel('dexterous.com/flutter/local_notifications');
    const MethodChannel secureStorageChannel =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

    setUp(() {
      didCallSystemNavigatorPop = false;

      // Mock SystemNavigator.pop platform call
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'SystemNavigator.pop') {
          didCallSystemNavigatorPop = true;
        }
        return null;
      });

      // Mock notifications channel to prevent unhandled MissingPluginException
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(notificationChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'pendingNotificationRequests') {
          return <Map<String, dynamic>>[];
        }
        return null;
      });

      // Mock secure storage
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(secureStorageChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'containsKey') return false;
        if (methodCall.method == 'read') return null;
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(notificationChannel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(secureStorageChannel, null);
    });

    testWidgets(
        'TC-1: First back press on OverviewPage shows exit SnackBar and does NOT exit',
        (WidgetTester tester) async {
      DateTime currentTime = DateTime(2025, 1, 1, 12, 0, 0);

      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: mainPageScaffold,
          home: OverviewPage(
            reloadModePage: () {},
            nowProvider: () => currentTime,
          ),
        ),
      );
      await tester.pump();

      // Trigger system back button once
      await tester.binding.handlePopRoute();
      await tester.pump();

      // Verify SnackBar is displayed and app has NOT called SystemNavigator.pop
      expect(find.byType(SnackBar), findsOneWidget);
      expect(didCallSystemNavigatorPop, isFalse);
    });

    testWidgets(
        'TC-2: Second back press within 2 seconds calls SystemNavigator.pop',
        (WidgetTester tester) async {
      DateTime currentTime = DateTime(2025, 1, 1, 12, 0, 0);

      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: mainPageScaffold,
          home: OverviewPage(
            reloadModePage: () {},
            nowProvider: () => currentTime,
          ),
        ),
      );
      await tester.pump();

      // 1st press at T0
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(didCallSystemNavigatorPop, isFalse);

      // Advance simulated time past debounce (300ms) but within 2-second window (500ms)
      currentTime = currentTime.add(const Duration(milliseconds: 500));

      // 2nd press within 2 seconds
      await tester.binding.handlePopRoute();
      await tester.pump();

      // Verify SystemNavigator.pop was invoked
      expect(didCallSystemNavigatorPop, isTrue);
    });

    testWidgets(
        'TC-3: Second back press after 2 seconds does NOT exit and restarts timer',
        (WidgetTester tester) async {
      DateTime currentTime = DateTime(2025, 1, 1, 12, 0, 0);

      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: mainPageScaffold,
          home: OverviewPage(
            reloadModePage: () {},
            nowProvider: () => currentTime,
          ),
        ),
      );
      await tester.pump();

      // 1st press at T0
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(didCallSystemNavigatorPop, isFalse);

      // Advance simulated time past the 2-second window (2500ms)
      currentTime = currentTime.add(const Duration(milliseconds: 2500));

      // 2nd press after timeout
      await tester.binding.handlePopRoute();
      await tester.pump();

      // Should NOT exit; timer resets and SnackBar is shown again
      expect(didCallSystemNavigatorPop, isFalse);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets(
        'TC-4: Rapid duplicate back press (< 300ms debounce) is ignored',
        (WidgetTester tester) async {
      DateTime currentTime = DateTime(2025, 1, 1, 12, 0, 0);

      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: mainPageScaffold,
          home: OverviewPage(
            reloadModePage: () {},
            nowProvider: () => currentTime,
          ),
        ),
      );
      await tester.pump();

      // 1st press at T0
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(didCallSystemNavigatorPop, isFalse);

      // Rapid duplicate event (e.g. Android gesture repeated dispatch after 50ms)
      currentTime = currentTime.add(const Duration(milliseconds: 50));
      await tester.binding.handlePopRoute();
      await tester.pump();

      // Debounce ignores it; app must NOT exit
      expect(didCallSystemNavigatorPop, isFalse);
    });

    testWidgets(
        'TC-5: NavigatorPopHandler in ModuleIndexPage pops nested subpages',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModuleIndexPage(reloadModePage: () {}),
          ),
        ),
      );
      await tester.pump();

      // Push a dummy subpage onto moduleNavigator (simulating ModulePage or ChapterPage)
      moduleNavigator.currentState!.push(
        MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Text('Subpage Screen'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Subpage Screen'), findsOneWidget);

      // Trigger back button - NavigatorPopHandler should pop the subpage back to OverviewPage
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // Subpage is popped; no longer present
      expect(find.text('Subpage Screen'), findsNothing);
    });

    testWidgets(
        'TC-6: Back press when on non-zero tab switches back to Overview tab (index 0)',
        (WidgetTester tester) async {
      // Ensure Localization is loaded so all tab widgets can render safely
      await LocalizationService().load(Language.german);

      await tester.pumpWidget(
        MaterialApp(
          home: MainPage(onThemeChanged: (_) {}),
        ),
      );
      await tester.pumpAndSettle();

      // Find bottom navigation bar and tap on Diary tab (index 1)
      final diaryTab = find.text(LocalizationService().get('diary'));
      expect(diaryTab, findsOneWidget);
      await tester.tap(diaryTab);
      await tester.pumpAndSettle();

      // Trigger back button while on tab 1
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // MainPage PopScope should switch back to tab 0 (Overview)
      // Verify app has NOT exited
      expect(didCallSystemNavigatorPop, isFalse);

      // Now trigger back button on tab 0 - should trigger OverviewPage SnackBar
      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
