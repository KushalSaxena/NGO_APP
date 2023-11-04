import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // Return null for success
    } catch (e) {
      return e.toString(); // Return an error message
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Return null for success
    } catch (e) {
      return e.toString(); // Return an error message
    }
  }

  Future signOut() async {
    await _auth.signOut();
  }
}
