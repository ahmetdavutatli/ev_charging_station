import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get user => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user in Firebase Authentication
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the created user
      User? firebaseUser = _firebaseAuth.currentUser;

      // Save user data to Firestore
      await _firestore.collection('users').doc(firebaseUser?.uid).set({
        'name': name,
        'email': email,
      });
    } catch (e) {
      // Handle registration failure (show error message, etc.)
      print('Registration failed: $e');
      rethrow; // Rethrow the exception to allow handling in the UI
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
