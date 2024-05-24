// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartcook_cor/screens/index.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      navigate();
    });
  }

  void navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;
    if (isFirstTime) {
      // This is the first time, you can add some onboarding logic here if needed.
      // For now, directly navigate to the login screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      // Check if the user is logged in
      final isLoggedIn = checkIfUserIsLoggedIn(); // Implement your own logic
      // Navigate to the appropriate screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              isLoggedIn ? const MainAppScreens() : const LoginScreen(),
        ),
      );
    }
  }

  // Implement checkIfUserIsLoggedIn() function to check user login status
  bool checkIfUserIsLoggedIn() {
    // Implement your logic to check if the user is logged in
    return false; // Replace with your actual logic
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child:
            CircularProgressIndicator(), // You can add a splash screen image here
      ),
    );
  }
}
