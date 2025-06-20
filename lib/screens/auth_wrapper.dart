import 'package:chatapp/screens/home_screen.dart';
import 'package:chatapp/screens/login_screen.dart';
import 'package:chatapp/screens/splaash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplaashScreen();
        }
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          return user == null ? LoginScreen() : HomeScreen();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
