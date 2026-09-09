import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adapt/services/localization_service.dart';
import 'package:adapt/enums/language.dart';
import 'package:adapt/widgets/bottom_nav_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Localization and BottomNavBar Dynamic Translation Tests', () {
    const MethodChannel secureStorageChannel =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(secureStorageChannel, (MethodCall methodCall) async {
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(secureStorageChannel, null);
    });

    testWidgets(
        'BottomNavBar immediately updates its labels when language changes without clicking tabs',
        (WidgetTester tester) async {
      // 1. Load German initially
      await LocalizationService().load(Language.german);

      int selectedTab = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavBar(
              currentIndex: selectedTab,
              onDestinationSelected: (index) {
                selectedTab = index;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify German labels are present
      expect(find.text('Übersicht'), findsOneWidget);
      expect(find.text('Übungsbuch'), findsOneWidget);
      expect(find.text('Overview'), findsNothing);
      expect(find.text('Workbook'), findsNothing);

      // 2. Change language to English dynamically (as done in SettingsPage)
      await LocalizationService().load(Language.english);
      await tester.pump();

      // Verify BottomNavBar immediately translated to English without any tab click
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Workbook'), findsOneWidget);
      expect(find.text('Übersicht'), findsNothing);
      expect(find.text('Übungsbuch'), findsNothing);

      // 3. Change back to German
      await LocalizationService().load(Language.german);
      await tester.pump();

      // Verify BottomNavBar immediately translated back to German
      expect(find.text('Übersicht'), findsOneWidget);
      expect(find.text('Übungsbuch'), findsOneWidget);
      expect(find.text('Overview'), findsNothing);
      expect(find.text('Workbook'), findsNothing);
    });
  });
}
