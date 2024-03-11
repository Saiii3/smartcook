import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartcook_cor/screens/index.dart';

class AppNavigation extends StatelessWidget {
  const AppNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            return const MainAppScreens(); // Authenticated user screens
          } else {
            return const RegistrationScreen(); // Login or registration screens
          }
        }
        return const CircularProgressIndicator(); // Loading indicator
      },
    );
  }
}

