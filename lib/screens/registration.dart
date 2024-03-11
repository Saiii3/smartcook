// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:smartcook_cor/screens/index.dart';
import 'package:smartcook_cor/utils/auth.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
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

  Future<void> _registerWithEmailAndPassword() async {
    EasyLoading.show(status: 'Registering in...');
    String email = _emailController.text;
    String password = _passwordController.text;

    if (_validateInput(email, password)) {
      final User? user =
          await _authService.registerWithEmailAndPassword(email, password);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainAppScreens()),
        );
        EasyLoading.showSuccess('Register Success!');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed. Please try again.'),
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
    EasyLoading.dismiss();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text('Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20.0),
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
            const SizedBox(height: 40.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize:
                    const Size.fromHeight(50), // makes the button taller
              ),
              onPressed: _registerWithEmailAndPassword,
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: DefaultTextStyle.of(context).style,
                  children: const <TextSpan>[
                    TextSpan(
                      text: 'Login',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange), // Highlighted text style
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
