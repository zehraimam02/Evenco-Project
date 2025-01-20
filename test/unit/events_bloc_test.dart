import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evenco_app/blocs/events/event_bloc.dart';
import 'package:evenco_app/models/event_model.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference {}
class MockDocumentReference extends Mock implements DocumentReference {}
class MockUser extends Mock implements User {}

void main() {
  group('EventsBloc Tests', () {
    late EventsBloc eventsBloc;
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      
      // Setup auth mock
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-user-id');
      when(mockUser.email).thenReturn('test@example.com');

      eventsBloc = EventsBloc();
    });

    blocTest<EventsBloc, EventsState>(
      'emits [EventsLoading, EventsLoaded] when LoadEventsEvent is added',
      build: () => eventsBloc,
      act: (bloc) => bloc.add(LoadEventsEvent()),
      expect: () => [
        isA<EventsLoading>(),
        isA<EventsLoaded>(),
      ],
    );

    blocTest<EventsBloc, EventsState>(
      'emits [EventsLoading, EventsLoaded] when CreateEventEvent is added',
      build: () => eventsBloc,
      act: (bloc) => bloc.add(CreateEventEvent(
        EventModel(
          id: '1',
          organizerId: 'test-user-id',
          title: 'Test Event',
          description: 'Test Description',
          date: DateTime.now(),
          time: const TimeOfDay(hour: 14, minute: 30),
          location: 'Test Location',
          budget: 500.0,
          createdAt: DateTime.now(),
        ),
      )),
      expect: () => [
        isA<EventsLoading>(),
        isA<EventsLoaded>(),
      ],
    );
  });
}