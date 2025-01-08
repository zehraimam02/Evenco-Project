import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:evenco_app/blocs/auth/auth_bloc.dart';
import 'package:evenco_app/routes/app_router.dart';

import 'blocs/events/budget_bloc.dart';
import 'blocs/events/event_bloc.dart';
import 'blocs/events/guest_bloc.dart';
import 'blocs/events/task_bloc.dart';
import 'firebase_options.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "project-evenco",
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => DatabaseService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<EventsBloc>(
          create: (_) => EventsBloc()
        ),
        BlocProvider<TasksBloc>(
          create: (_) => TasksBloc(),
        ),
        BlocProvider<GuestsBloc>(
          create: (_) => GuestsBloc(),
        ),
        BlocProvider<BudgetBloc>(
          create: (context) => BudgetBloc(context.read<DatabaseService>()),
        ),
      ],
      child: MaterialApp(
        title: 'Evenco',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}