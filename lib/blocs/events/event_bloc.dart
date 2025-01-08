import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evenco_app/models/event_model.dart';

// Events
abstract class EventsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadEventsEvent extends EventsEvent {}

class CreateEventEvent extends EventsEvent {
  final EventModel event;
  CreateEventEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class UpdateEventEvent extends EventsEvent {
  final EventModel event;
  UpdateEventEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class DeleteEventEvent extends EventsEvent {
  final String eventId;
  DeleteEventEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class ToggleFavoriteEvent extends EventsEvent {
  final String eventId;
  ToggleFavoriteEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

// States
abstract class EventsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EventsInitial extends EventsState {}
class EventsLoading extends EventsState {}
class EventsLoaded extends EventsState {
  final List<EventModel> events;
  EventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
}
class EventsFailure extends EventsState {
  final String message;
  EventsFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  EventsBloc() : super(EventsInitial()) {
    on<LoadEventsEvent>(_onLoadEvents);
    on<CreateEventEvent>(_onCreateEvent);
    on<UpdateEventEvent>(_onUpdateEvent);
    on<DeleteEventEvent>(_onDeleteEvent);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onLoadEvents(
    LoadEventsEvent event,
    Emitter<EventsState> emit,
  ) async {
    emit(EventsLoading());
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(EventsFailure('User not authenticated'));
        return;
      }

      final snapshot = await _firestore.collection('events')
          .where('organizerId', isEqualTo: currentUser.uid)
          .get();

      final guestSnapshot = await _firestore.collection('guests')
          .where('email', isEqualTo: currentUser.email)
          .get();

      // Combine both results
      final allDocs = [...snapshot.docs, ...guestSnapshot.docs];
      // Remove duplicates if any by converting to Set and back to List
      final uniqueDocs = allDocs.toSet().toList();
      
      final events = uniqueDocs
          .map((doc) => EventModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      
      emit(EventsLoaded(events));
    } catch (e) {
      emit(EventsFailure(e.toString()));
    }
  }

  Future<void> _onCreateEvent(
    CreateEventEvent event,
    Emitter<EventsState> emit,
  ) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(EventsFailure('User not authenticated'));
        return;
      }

      // Create a new event with the current user as organizer
      final newEvent = {
        ...event.event.toMap(),
        'organizerId': currentUser.uid,
      };

      await _firestore.collection('events').add(newEvent);
      add(LoadEventsEvent());
    } catch (e) {
      emit(EventsFailure(e.toString()));
    }
  }

  Future<void> _onUpdateEvent(
    UpdateEventEvent event,
    Emitter<EventsState> emit,
  ) async {
    try {
      await _firestore
          .collection('events')
          .doc(event.event.id)
          .update(event.event.toMap());
      add(LoadEventsEvent());
    } catch (e) {
      emit(EventsFailure(e.toString()));
    }
  }

  Future<void> _onDeleteEvent(
    DeleteEventEvent event,
    Emitter<EventsState> emit,
  ) async {
    try {
      await _firestore.collection('events').doc(event.eventId).delete();
      add(LoadEventsEvent());
    } catch (e) {
      emit(EventsFailure(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<EventsState> emit,
  ) async {
    if (state is EventsLoaded) {
      final currentState = state as EventsLoaded;
      final eventIndex = currentState.events
          .indexWhere((element) => element.id == event.eventId);
      
      if (eventIndex != -1) {
        final updatedEvent = currentState.events[eventIndex]
            .copyWith(isFavorite: !currentState.events[eventIndex].isFavorite);
        
        try {
          await _firestore
              .collection('events')
              .doc(event.eventId)
              .update({'isFavorite': updatedEvent.isFavorite});
          
          final updatedEvents = List<EventModel>.from(currentState.events);
          updatedEvents[eventIndex] = updatedEvent;
          emit(EventsLoaded(updatedEvents));
        } catch (e) {
          emit(EventsFailure(e.toString()));
        }
      }
    }
  }
}