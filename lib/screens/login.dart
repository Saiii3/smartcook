// ignore_for_file: use_build_context_synchronously, unused_element

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:smartcook_cor/screens/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartcook_cor/utils/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Add listener to password controller
    _passwordController.addListener(() {
      // If there is text in the password field, show the visibility icon
      if (_passwordController.text.isNotEmpty) {
        setState(() {
          _passwordVisible = false;
        });
      } else {
        // If the text field is empty, hide the visibility icon
        setState(() {
          _passwordVisible = true;
        });
      }
    });
  }

  Future<void> _signInWithEmailAndPassword() async {
    EasyLoading.show(status: 'Logging in...'); // Show loading indicator
    // Use the text from the controllers
    String email = _emailController.text;
    String password = _passwordController.text;

    if (_validateInput(email, password)) {
      final User? user =
          await _authService.signInWithEmailAndPassword(email, password);
      EasyLoading.dismiss(); // Hide loading indicator
      if (user != null) {
        if (user.email == 'admin@gmail.com') {
          // Navigate to the AdminDashboardScreen if the user is the admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen()),
          );
          EasyLoading.showSuccess('Admin Login Success!');
        } else {
          // Navigate to the MainAppScreens after successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainAppScreens()),
          );
          EasyLoading.showSuccess('Log in Success!');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Login failed. Please check your email and password.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the input fields.'),
        ),
      );
    }
  }

  // Update the _validateInput function to take parameters
  bool _validateInput(String email, String password) {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A valid email is required.'),
        ),
      );
      return false;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _signInWithGoogle() async {
    final User? user = await _authService.signInWithGoogle();
    if (user != null) {
      // Google Sign-In successful, you can navigate to another screen or show a success message.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainAppScreens()),
      );
      EasyLoading.showSuccess('Google Login Success!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Center(
          child: Text(
            '🍚',
            style: TextStyle(fontSize: 50),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or any other widget for the top section
              // const FlutterLogo(size: 100),
              const SizedBox(height: 140),

              // Email TextField
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Password TextField
              // Password TextField
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  // Show the visibility toggle icon only if there is text in the password field
                  suffixIcon: _passwordController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        )
                      : null,
                ),
                obscureText: !_passwordVisible,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 20),

              // Log In Button
              ElevatedButton(
                onPressed: _signInWithEmailAndPassword,
                style: ElevatedButton.styleFrom(
                  minimumSize:
                      const Size.fromHeight(50), // Set the button height
                ),
                child: const Text('Log In'),
              ),
              const SizedBox(height: 10),

              // Register Button
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegistrationScreen()),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: DefaultTextStyle.of(context).style,
                    children: const <TextSpan>[
                      TextSpan(
                        text: 'Register here',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange), // Highlighted text style
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Google Sign-In Button
              ElevatedButton.icon(
                onPressed: _signInWithGoogle,
                icon: SvgPicture.asset(
                  'asset/svg/GoogleIcons.svg', // Update the path to your SVG file
                  width: 24,
                  height: 24,
                ),
                label: const Text('Log In with Google'),
                style: ElevatedButton.styleFrom(
                  minimumSize:
                      const Size.fromHeight(50), // Set the button height
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
