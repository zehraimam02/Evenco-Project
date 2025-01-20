import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evenco_app/models/event_model.dart';

void main() {
  group('EventModel Tests', () {
    final testDate = DateTime(2025, 2, 15);
    final testTime = const TimeOfDay(hour: 14, minute: 30);
    
    test('Create EventModel with valid data', () {
      final event = EventModel(
        id: '1',
        organizerId: 'user123',
        title: 'Tech Conference',
        description: 'Annual tech meetup',
        date: testDate,
        time: testTime,
        location: 'Convention Center',
        budget: 1000.0,
        createdAt: testDate,
      );

      expect(event.title, equals('Tech Conference'));
      expect(event.description, equals('Annual tech meetup'));
      expect(event.budget, equals(1000.0));
      expect(event.guests, isEmpty);
      expect(event.tasks, isEmpty);
      expect(event.isFavorite, isFalse);
    });

    test('Convert EventModel to Map', () {
      final event = EventModel(
        id: '1',
        organizerId: 'user123',
        title: 'Test Event',
        description: 'Test Description',
        date: testDate,
        time: testTime,
        location: 'Test Location',
        budget: 500.0,
        createdAt: testDate,
      );

      final map = event.toMap();

      expect(map['id'], equals('1'));
      expect(map['title'], equals('Test Event'));
      expect(map['time'], equals({'hour': 14, 'minute': 30}));
      expect(map['budget'], equals(500.0));
    });

    test('Create EventModel from Map', () {
      final map = {
        'id': '1',
        'organizerId': 'user123',
        'title': 'Test Event',
        'description': 'Test Description',
        'date': Timestamp.fromDate(testDate),
        'time': {'hour': 14, 'minute': 30},
        'location': 'Test Location',
        'budget': 500.0,
        'guests': <String>[],
        'tasks': <String>[],
        'isFavorite': false,
        'createdAt': Timestamp.fromDate(testDate),
      };

      final event = EventModel.fromMap(map);

      expect(event.id, equals('1'));
      expect(event.title, equals('Test Event'));
      expect(event.time.hour, equals(14));
      expect(event.time.minute, equals(30));
      expect(event.budget, equals(500.0));
    });

    test('Test copyWith method', () {
      final event = EventModel(
        id: '1',
        organizerId: 'user123',
        title: 'Original Title',
        description: 'Original Description',
        date: testDate,
        time: testTime,
        location: 'Original Location',
        budget: 500.0,
        createdAt: testDate,
      );

      final updatedEvent = event.copyWith(
        title: 'Updated Title',
        budget: 1000.0,
      );

      expect(updatedEvent.id, equals('1'));
      expect(updatedEvent.title, equals('Updated Title'));
      expect(updatedEvent.description, equals('Original Description'));
      expect(updatedEvent.budget, equals(1000.0));
    });
  });
}