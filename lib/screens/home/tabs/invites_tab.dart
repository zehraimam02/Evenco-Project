import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/events/guest_bloc.dart';
import '../../../models/event_model.dart';
import '../../../models/guest_model.dart';

class InvitesTab extends StatelessWidget {
  const InvitesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Invitations'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('guests')
            .where('email', isEqualTo: currentUserEmail?.toLowerCase())
            .snapshots(),
        builder: (context, guestSnapshot) {
          if (guestSnapshot.hasError) {
            return Center(child: Text('Error: ${guestSnapshot.error}'));
          }

          if (!guestSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final guests = guestSnapshot.data!.docs
              .map((doc) => GuestModel.fromJson(
                  {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
              .toList();

          if (guests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mail_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No invitations yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: guests.length,
            itemBuilder: (context, index) {
              final guest = guests[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('events')
                    .doc(guest.eventId)
                    .get(),
                builder: (context, eventSnapshot) {
                  if (eventSnapshot.connectionState == ConnectionState.waiting) {
                    return const Card(
                      child: ListTile(
                        title: LinearProgressIndicator(),
                      ),
                    );
                  }

                  if (eventSnapshot.hasError) {
                    return Card(
                      child: ListTile(
                        title: Text('Error loading event'), // Better error message
                      ),
                    );
                  }

                  if (!eventSnapshot.hasData || !eventSnapshot.data!.exists) {
                    return const Card(
                      child: ListTile(
                        title: Text('Event not found'), // Handle missing event
                      ),
                    );
                  }

                  final eventData =
                      eventSnapshot.data!.data() as Map<String, dynamic>;
                  final event = EventModel.fromMap(
                      {...eventData, 'id': eventSnapshot.data!.id});

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Icon(Icons.event, color: Colors.white),
                      ),
                      title: Text(event.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.description),
                          const SizedBox(height: 4),
                          Text(
                            'RSVP Status: ${guest.rsvpStatus.toString().split('.').last}',
                            style: TextStyle(
                              color: _getRsvpStatusColor(guest.rsvpStatus),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<RSVPStatus>(
                        onSelected: (RSVPStatus status) {
                          context.read<GuestsBloc>().add(
                                UpdateGuestRSVPEvent(guest.id, status),
                              );
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(
                            value: RSVPStatus.accepted,
                            child: Text('Accept'),
                          ),
                          const PopupMenuItem(
                            value: RSVPStatus.declined,
                            child: Text('Decline'),
                          ),
                          const PopupMenuItem(
                            value: RSVPStatus.maybe,
                            child: Text('Maybe'),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/events/details',
                          arguments: event,
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Color _getRsvpStatusColor(RSVPStatus status) {
    switch (status) {
      case RSVPStatus.accepted:
        return Colors.green;
      case RSVPStatus.declined:
        return Colors.red;
      case RSVPStatus.maybe:
        return Colors.orange;
      case RSVPStatus.pending:
        return Colors.grey;
    }
  }
}