import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();

    Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult = await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          await _setOfflineUser(user.uid);
        }

        return user;
      }
      return null; // User canceled the Google sign-in
    } catch (e) {
      _logger.e(e.toString());
      return null; // Handle login errors
    }
  }

  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = authResult.user;

      if (user != null) {
        await _setOfflineUser(user.uid);
      }

      return user;
    } catch (e) {
      _logger.e(e.toString());
      return null; // Handle registration errors
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = authResult.user;

      if (user != null) {
        await _setOfflineUser(user.uid);
      }

      return user;
    } catch (e) {
      _logger.e(e.toString());
      return null; // Handle login errors
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _removeOfflineUser();
  }

  // Set the offline user ID in SharedPreferences
  Future<void> _setOfflineUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('offlineUserId', userId);
  }

  // Remove the offline user ID from SharedPreferences
  Future<void> _removeOfflineUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('offlineUserId');
  }

  // Get the offline user ID from SharedPreferences
  Future<User?> getOfflineUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('offlineUserId');
    
    if (userId != null) {
      return _auth.currentUser;
    } else {
      return null;
    }
  }

  
}
