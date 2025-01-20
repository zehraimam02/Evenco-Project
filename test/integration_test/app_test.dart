import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:evenco_app/main.dart';
import 'package:flutter/material.dart';
import 'package:evenco_app/models/event_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:evenco_app/blocs/events/event_bloc.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test', () {
    testWidgets('Complete event flow test', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify we're on the events tab
      expect(find.text('My Events'), findsOneWidget);

      // Test favorite filter
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();
      expect(find.text('Favorite Events'), findsOneWidget);

      // Test unfavorite filter
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();
      expect(find.text('My Events'), findsOneWidget);

      // Verify empty state message
      expect(
        find.text('No events yet. Create your first event!'),
        findsOneWidget,
      );
    });
  });
}