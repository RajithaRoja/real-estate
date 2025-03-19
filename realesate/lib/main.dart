import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:realesate/admin_property_approve/admin_property_list.dart';
import 'package:realesate/agent_user_list/agent_user_list.dart';

import 'firebase_options.dart';
import 'property/property_bloc.dart';
import 'property/property_event.dart';
import 'repositories/property_repository.dart';
import 'screens/login.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PropertyBloc(
            PropertyRepository(),
          )..add(LoadProperties()),
        ),
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Real Estate App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
        routes: {
          '/home': (context) => AdminPropertyListPage(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
} 