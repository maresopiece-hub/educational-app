import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'dart:io' show Platform;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'user-not-found') {
        // Known auth errors that the UI can interpret as invalid credentials.
        debugPrint('Auth sign-in failed: ${e.code} - ${e.message}');
      } else {
        debugPrint('Auth sign-in error: ${e.code} - ${e.message}');
      }
      return null;
    }
  }

  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // Create user profile in Firestore
      await _db.collection('users').doc(result.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        debugPrint('Email is already registered. Try logging in.');
      } else {
        debugPrint('Auth register error: ${e.code} - ${e.message}');
      }
      return null;
    }
  }

  /// Alias for registerWithEmail to match alternative naming in other code/snippets.
  Future<User?> signUpWithEmail(String email, String password) async {
    return registerWithEmail(email, password);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<User?> signInWithGoogle() async {
    if (!(kIsWeb || Platform.isAndroid || Platform.isIOS)) {
      throw UnsupportedError('Google sign-in is not supported on this platform.');
    }
    // Google sign-in logic for supported platforms only
    throw UnimplementedError('Google sign-in must be implemented for supported platforms.');
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
