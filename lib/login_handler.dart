//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';

// ...

//await Firebase.initializeApp(
//    options: DefaultFirebaseOptions.currentPlatform,
//);

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'onboarding_page.dart';

import 'home_screen.dart';
import 'login_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  SharedPreferences? prefs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return LoginPage();//OnboardingPage();
          }
        },
      )
    );
  }
}