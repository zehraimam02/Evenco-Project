import 'package:evenco_app/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:evenco_app/screens/home/tabs/events_tab.dart';
import 'package:evenco_app/blocs/events/event_bloc.dart';

class MockEventsBloc extends Mock implements EventsBloc {}

void main() {
  group('EventsTab Widget Tests', () {
    late MockEventsBloc mockEventsBloc;

    setUp(() {
      mockEventsBloc = MockEventsBloc();
    });

    testWidgets('shows loading indicator when loading events',
        (WidgetTester tester) async {
      when(mockEventsBloc.state).thenReturn(EventsLoading());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<EventsBloc>.value(
            value: mockEventsBloc,
            child: const EventsTab(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty message when no events',
        (WidgetTester tester) async {
      when(mockEventsBloc.state).thenReturn(EventsLoaded([]));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<EventsBloc>.value(
            value: mockEventsBloc,
            child: const EventsTab(),
          ),
        ),
      );

      expect(find.text('No events yet. Create your first event!'),
          findsOneWidget);
    });

    testWidgets('shows event cards when events are loaded',
        (WidgetTester tester) async {
      final events = [
        EventModel(
          id: '1',
          organizerId: 'user123',
          title: 'Test Event',
          description: 'Test Description',
          date: DateTime.now(),
          time: const TimeOfDay(hour: 14, minute: 30),
          location: 'Test Location',
          budget: 500.0,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockEventsBloc.state).thenReturn(EventsLoaded(events));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<EventsBloc>.value(
            value: mockEventsBloc,
            child: const EventsTab(),
          ),
        ),
      );

      expect(find.text('Test Event'), findsOneWidget);
      expect(find.byType(EventCard), findsOneWidget);
    });

    testWidgets('toggles favorite filter when favorite button is pressed',
        (WidgetTester tester) async {
      when(mockEventsBloc.state).thenReturn(EventsLoaded([]));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<EventsBloc>.value(
            value: mockEventsBloc,
            child: const EventsTab(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pump();

      expect(find.text('Favorite Events'), findsOneWidget);
    });
  });
}