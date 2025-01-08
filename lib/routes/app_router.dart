
import 'package:flutter/material.dart';
import 'package:evenco_app/models/event_model.dart';
import 'package:evenco_app/screens/splash_screen.dart';
import 'package:evenco_app/screens/auth/login_screen.dart';
import 'package:evenco_app/screens/auth/signup_screen.dart';
import 'package:evenco_app/screens/home/home_screen.dart';
import 'package:evenco_app/screens/events/create_event_screen.dart';
import 'package:evenco_app/screens/events/event_details_screen.dart';

import '../screens/events/budget/manage_budget_screen.dart';
import '../screens/events/guests/add_guest_screen.dart';
import '../screens/events/tasks/add_task_screen.dart';
import '../screens/events/edit_event_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/auth/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/auth/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/events/create':
        return MaterialPageRoute(builder: (_) => const CreateEventScreen());

      case '/events/details':
        final event = settings.arguments as EventModel;
        return MaterialPageRoute(
          builder: (_) => EventDetailsScreen(event: event),
        );

      case '/events/edit':
        final event = settings.arguments as EventModel;
        return MaterialPageRoute(
          builder: (_) => EditEventScreen(event: event),
        );

      case '/events/guests': 
        final event = settings.arguments as EventModel;
        return MaterialPageRoute(
          builder: (_) => AddGuestScreen(event: event, eventId: event.id),
        );
      case '/events/tasks': 
        final event = settings.arguments as EventModel;
        return MaterialPageRoute(
          builder: (_) => AddTaskScreen(event: event),
        );
      case '/events/budget': 
        final event = settings.arguments as EventModel;
        return MaterialPageRoute(
          builder: (_) => ManageBudgetScreen(event: event),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}