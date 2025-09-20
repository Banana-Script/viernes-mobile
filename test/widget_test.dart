// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:viernes_mobile/main.dart';
import 'package:viernes_mobile/shared/providers/app_providers.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const ViernesApp(),
      ),
    );

    // Verify that the app loads and shows the splash screen
    expect(find.text('Viernes'), findsOneWidget);
    expect(find.text('AI-Powered Business Assistant'), findsOneWidget);
  });
}
