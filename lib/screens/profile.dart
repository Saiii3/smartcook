// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartcook_cor/screens/index.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ProfileScreen extends StatefulWidget {
  final User? user;

  const ProfileScreen({Key? key, this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _signOut(BuildContext context) async {
    final scaffoldContext = ScaffoldMessenger.of(context);

    try {
      await FirebaseAuth.instance.signOut();
      // After signing out, navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      // Handle any sign-out errors, such as displaying an error message.
      logger.e(e.toString()); // Error message
      logger.d('User signed out successfully'); // Debug message

      // Display an error message using the scaffold context
      scaffoldContext.showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        title: const Text('Profile'),
        // Removed IconButton for FavoriteRecipesScreen
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.user != null)
              Text(
                  'Email: ${widget.user!.email}'), // Display user's email if available
            ElevatedButton(
              onPressed: () {
                _signOut(context);
              },
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
