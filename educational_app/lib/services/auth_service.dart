
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';


class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Register with Email/Password
  Future<AppUser?> registerWithEmail(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user == null) return null;
      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'email': user.email,
        'name': name,
        'plans': [],
        'progress': {},
      }, SetOptions(merge: true));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.uid);
      await prefs.setString('user_email', user.email ?? '');
      await prefs.setString('user_name', name);
      return AppUser(
        id: user.uid,
        email: user.email ?? '',
        name: name,
        plans: [],
        progress: {},
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;
      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'email': user.email,
        'name': user.displayName ?? '',
        'plans': [],
        'progress': {},
      }, SetOptions(merge: true));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.uid);
      await prefs.setString('user_email', user.email ?? '');
      await prefs.setString('user_name', user.displayName ?? '');
      return AppUser(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        plans: [],
        progress: {},
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Email/Password
  Future<AppUser?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user == null) return null;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.uid);
      await prefs.setString('user_email', user.email ?? '');
      await prefs.setString('user_name', data['name'] ?? '');
      return AppUser(
        id: user.uid,
        email: user.email ?? '',
        name: data['name'] ?? '',
        plans: List<String>.from(data['plans'] ?? []),
        progress: (data['progress'] as Map<String, dynamic>? ?? {}).map((k, v) => MapEntry(k, (v as num).toDouble())),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
  }
}

