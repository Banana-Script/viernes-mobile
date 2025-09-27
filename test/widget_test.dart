// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:viernes_mobile/main.dart';

void main() {
  testWidgets('Viernes Mobile app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ViernesApp());

    // Verify that our app loads with Hello World text.
    expect(find.text('Hello World!'), findsOneWidget);
    expect(find.text('Welcome to Viernes Mobile'), findsOneWidget);

    // Tap the 'Get Started' button and trigger a frame.
    await tester.tap(find.text('Get Started'));
    await tester.pump();

    // Verify that the snackbar appears.
    expect(find.text('Button pressed!'), findsOneWidget);
  });
}
