// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:evenco_app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evenco_app/main.dart';

void main() {
  testWidgets('Evenco Golden Test', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
        ),
        home: const HomeScreen(),
      ),
    );

    // Wait for any animations to complete
    await tester.pumpAndSettle();

    // Take the screenshot
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('ui_sc.dart.png'),
    );
  });
}
