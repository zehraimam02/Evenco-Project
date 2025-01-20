import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:evenco_app/screens/home/tabs/events_tab.dart';
import 'package:evenco_app/models/event_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:evenco_app/blocs/events/event_bloc.dart';

void main() {
  // Set up fake device sizes for testing
  const devices = <String, Size>{
    'iPhone SE': Size(375, 667),
    'Pixel 5': Size(393, 851),
    'iPhone 12': Size(390, 844),
  };

  setUpAll(() {
    // This is important for golden tests to work correctly
    debugDisableShadows = false;
  });

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('EventCard Golden Tests', () {
    final testEvent = EventModel(
      id: '1',
      organizerId: 'test-user',
      title: 'Test Event',
      description: 'Test Description',
      date: DateTime(2025, 1, 1),
      time: const TimeOfDay(hour: 14, minute: 30),
      location: 'Test Location',
      budget: 1000.0,
      createdAt: DateTime.now(),
    );

    testWidgets('EventCard matches golden file', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          BlocProvider(
            create: (context) => EventsBloc(),
            child: EventCard(event: testEvent),
          ),
        ),
      );

      await expectLater(
        find.byType(EventCard),
        matchesGoldenFile('goldens/event_card.png'),
      );
    });

    // Test card in dark mode
    testWidgets('EventCard matches golden file in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          home: Scaffold(
            body: BlocProvider(
              create: (context) => EventsBloc(),
              child: EventCard(event: testEvent),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(EventCard),
        matchesGoldenFile('goldens/event_card_dark.png'),
      );
    });
  });

  group('EventsTab Golden Tests', () {
    for (final device in devices.entries) {
      testWidgets('EventsTab matches golden file on ${device.key}',
          (tester) async {
        // Set the screen size to match the device
        tester.binding.window.physicalSizeTestValue = device.value;
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider(
              create: (context) => EventsBloc(),
              child: const EventsTab(),
            ),
          ),
        );

        await expectLater(
          find.byType(EventsTab),
          matchesGoldenFile('goldens/events_tab_${device.key.toLowerCase()}.png'),
        );
      });
    }
  });
}