import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projekt_cg/home_screen.dart';
import 'firebase_options.dart';
import 'login_handler.dart';
import 'firebase_noti.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseNoti().initNotifications();
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        fontFamily: 'Roboto',
      ),
      home: AuthPage(),         //LoginPage(),//HomeScreen(),
      navigatorKey: navigatorKey,
      routes: {
        '/notification': (context) => const HomeScreen(),
    },
    );
  }
}
