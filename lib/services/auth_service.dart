import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithGoogle() async {
    if (!(kIsWeb || Platform.isAndroid || Platform.isIOS)) {
      throw UnsupportedError('Google sign-in is not supported on this platform.');
    }
    // Google sign-in logic for supported platforms only
    throw UnimplementedError('Google sign-in must be implemented for supported platforms.');
  }

  Future<User?> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    await _persistUser(userCredential.user);
    return userCredential.user;
  }

  Future<User?> signUpWithEmail(String email, String password, String name) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await userCredential.user?.updateDisplayName(name);
    await _persistUser(userCredential.user);
    return userCredential.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> _persistUser(User? user) async {
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.uid);
    await prefs.setString('user_email', user.email ?? '');
    await prefs.setString('user_name', user.displayName ?? '');
    await prefs.setString('user_avatar', user.photoURL ?? '');
  }

  User? get currentUser => _auth.currentUser;
}
