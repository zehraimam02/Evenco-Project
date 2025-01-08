import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:evenco_app/models/guest_model.dart';

// Events
abstract class GuestsEvent extends Equatable {
  const GuestsEvent();

  @override
  List<Object> get props => [];
}

class LoadGuests extends GuestsEvent {
  final String eventId;

  const LoadGuests(this.eventId);

  @override
  List<Object> get props => [eventId];
}

class AddGuestEvent extends GuestsEvent {
  final GuestModel guest;

  const AddGuestEvent(this.guest);

  @override
  List<Object> get props => [guest];
}

class UpdateGuestEvent extends GuestsEvent {
  final GuestModel guest;

  const UpdateGuestEvent(this.guest);

  @override
  List<Object> get props => [guest];
}

class DeleteGuestEvent extends GuestsEvent {
  final String guestId;

  const DeleteGuestEvent(this.guestId);

  @override
  List<Object> get props => [guestId];
}

class UpdateGuestRSVPEvent extends GuestsEvent {
  final String guestId;
  final RSVPStatus newStatus;

  const UpdateGuestRSVPEvent(this.guestId, this.newStatus);

  @override
  List<Object> get props => [guestId, newStatus];
}

// States
abstract class GuestsState extends Equatable {
  const GuestsState();

  @override
  List<Object> get props => [];
}

class GuestsInitial extends GuestsState {}

class GuestsLoading extends GuestsState {}

class GuestsLoaded extends GuestsState {
  final List<GuestModel> guests;

  const GuestsLoaded(this.guests);

  @override
  List<Object> get props => [guests];
}

class GuestsError extends GuestsState {
  final String message;

  const GuestsError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class GuestsBloc extends Bloc<GuestsEvent, GuestsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GuestsBloc() : super(GuestsInitial()) {
    on<LoadGuests>(_onLoadGuests);
    on<AddGuestEvent>(_onAddGuest);
    on<UpdateGuestEvent>(_onUpdateGuest);
    on<DeleteGuestEvent>(_onDeleteGuest);
    on<UpdateGuestRSVPEvent>(_onUpdateGuestRSVP);
  }

  Future<void> _onLoadGuests(LoadGuests event, Emitter<GuestsState> emit) async {
    emit(GuestsLoading());
    try {
      final snapshot = await _firestore
          .collection('guests')
          .where('eventId', isEqualTo: event.eventId)
          .get();

      final guests = snapshot.docs
          .map((doc) => GuestModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      emit(GuestsLoaded(guests));
    } catch (e) {
      emit(GuestsError(e.toString()));
    }
  }

  Future<void> _onAddGuest(AddGuestEvent event, Emitter<GuestsState> emit) async {
    try {
      if (state is GuestsLoaded) {
        await _firestore.collection('guests').add(event.guest.toJson());
        add(LoadGuests(event.guest.eventId));
      }
    } catch (e) {
      emit(GuestsError(e.toString()));
    }
  }

  Future<void> _onUpdateGuest(UpdateGuestEvent event, Emitter<GuestsState> emit) async {
    try {
      await _firestore
          .collection('guests')
          .doc(event.guest.id)
          .update(event.guest.toJson());
      add(LoadGuests(event.guest.eventId));
    } catch (e) {
      emit(GuestsError(e.toString()));
    }
  }

  Future<void> _onDeleteGuest(DeleteGuestEvent event, Emitter<GuestsState> emit) async {
    try {
      if (state is GuestsLoaded) {
        final currentState = state as GuestsLoaded;
        final guestToDelete = currentState.guests.firstWhere((guest) => guest.id == event.guestId);

        await _firestore.collection('guests').doc(event.guestId).delete();
        add(LoadGuests(guestToDelete.eventId));
      }
    } catch (e) {
      emit(GuestsError(e.toString()));
    }
  }

  Future<void> _onUpdateGuestRSVP(
    UpdateGuestRSVPEvent event,
    Emitter<GuestsState> emit,
  ) async {
    try {
      if (state is GuestsLoaded) {
        final currentState = state as GuestsLoaded;
        final guest = currentState.guests.firstWhere((g) => g.id == event.guestId);
        final updatedGuest = guest.copyWith(rsvpStatus: event.newStatus);

        add(UpdateGuestEvent(updatedGuest));
      }
    } catch (e) {
      emit(GuestsError(e.toString()));
    }
  }
}
