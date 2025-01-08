import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:evenco_app/blocs/events/event_bloc.dart';
import 'package:evenco_app/models/event_model.dart';
import 'package:intl/intl.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  bool _showFavorites = false;

  @override
  void initState() {
    super.initState();
    context.read<EventsBloc>().add(LoadEventsEvent());
  }

  List<EventModel> _filterEvents(List<EventModel> events) {
    if (_showFavorites) {
      return events.where((event) => event.isFavorite).toList();
    }
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showFavorites ? 'Favorite Events' : 'My Events'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: _showFavorites ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _showFavorites = !_showFavorites;
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<EventsBloc, EventsState>(
        builder: (context, state) {
          if (state is EventsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is EventsFailure) {
            return Center(child: Text(state.message));
          }
          
          if (state is EventsLoaded) {
            final filteredEvents = _filterEvents(state.events);
            
            if (filteredEvents.isEmpty) {
              return Center(
                child: Text(
                  _showFavorites 
                    ? 'No favorite events yet'
                    : 'No events yet. Create your first event!'
                ),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return EventCard(event: event);
              },
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// EventCard widget
class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/events/details',
            arguments: event,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      event.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: event.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      context.read<EventsBloc>().add(
                            ToggleFavoriteEvent(event.id),
                          );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy').format(event.date),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    event.time.format(context),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    event.location,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}