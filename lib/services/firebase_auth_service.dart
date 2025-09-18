import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Lightweight AuthService wrapper that is safe to construct in test
/// environments where Firebase may not be initialized. Accessors that
/// depend on Firebase are guarded and will return null or no-op values
/// when Firebase isn't available.
class AuthService {
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  User? get currentUser => _auth?.currentUser;

  Stream<User?> get authStateChanges => _auth?.authStateChanges() ?? Stream.value(null);

  Future<User?> signInWithEmail(String email, String password) async {
    final auth = _auth;
    if (auth == null) throw StateError('Firebase not initialized');
    final result = await auth.signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  Future<User?> registerWithEmail(String email, String password) async {
    final auth = _auth;
    final db = _db;
    if (auth == null || db == null) throw StateError('Firebase not initialized');
    final result = await auth.createUserWithEmailAndPassword(email: email, password: password);
    // Create user profile in Firestore
    await db.collection('users').doc(result.user!.uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return result.user;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final auth = _auth;
    if (auth == null) throw StateError('Firebase not initialized');
    await auth.sendPasswordResetEmail(email: email);
  }

  Future<User?> signInWithGoogle() async {
    if (!(kIsWeb || Platform.isAndroid || Platform.isIOS)) {
      throw UnsupportedError('Google sign-in is not supported on this platform.');
    }
    // Google sign-in logic for supported platforms only
    throw UnimplementedError('Google sign-in must be implemented for supported platforms.');
  }

  Future<void> signOut() async {
    final auth = _auth;
    if (auth == null) return;
    await auth.signOut();
  }
}
