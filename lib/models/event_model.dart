import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventModel {
  final String id;
  final String organizerId;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final String location;
  final double budget;
  final List<String> guests;
  final List<String> tasks;
  final bool isFavorite;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.organizerId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.budget,
    this.guests = const [],
    this.tasks = const [],
    this.isFavorite = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizerId': organizerId,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'time': {'hour': time.hour, 'minute': time.minute},
      'location': location,
      'budget': budget,
      'guests': guests,
      'tasks': tasks,
      'isFavorite': isFavorite,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] ?? '',
      organizerId: map['organizerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      time: TimeOfDay(  // Parse time components
        hour: (map['time'] as Map<String, dynamic>)['hour'],
        minute: (map['time'] as Map<String, dynamic>)['minute'],
      ),
      location: map['location'] ?? '',
      budget: (map['budget'] ?? 0.0).toDouble(),
      guests: List<String>.from(map['guests'] ?? []),
      tasks: List<String>.from(map['tasks'] ?? []),
      isFavorite: map['isFavorite'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  EventModel copyWith({
    String? id,
    String? organizerId,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    String? location,
    double? budget,
    List<String>? guests,
    List<String>? tasks,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      organizerId: organizerId ?? this.organizerId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      budget: budget ?? this.budget,
      guests: guests ?? this.guests,
      tasks: tasks ?? this.tasks,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}