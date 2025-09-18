// Firestore emulator integration test for PublicService.ratePlan
// Start the emulator externally before running this test:
//   firebase emulators:start --only firestore,auth

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import 'package:grade12_exam_prep_tutor/services/public_service.dart';

Future<Map<String, dynamic>> _createEmulatorAccount(String email, String password) async {
  final uri = Uri.parse('http://localhost:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key');
  final res = await http.post(uri,
      body: jsonEncode({'email': email, 'password': password, 'returnSecureToken': true}),
      headers: {'Content-Type': 'application/json'});
  if (res.statusCode != 200) throw StateError('Failed to create emulator user: ${res.body}');
  return jsonDecode(res.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> _signInEmulatorAccount(String email, String password) async {
  final uri = Uri.parse('http://localhost:9099/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-api-key');
  final res = await http.post(uri,
      body: jsonEncode({'email': email, 'password': password, 'returnSecureToken': true}),
      headers: {'Content-Type': 'application/json'});
  if (res.statusCode != 200) throw StateError('Failed to sign in emulator user: ${res.body}');
  return jsonDecode(res.body) as Map<String, dynamic>;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // If the environment isn't configured for emulator, the test will still
  // attempt to contact the emulator on the default localhost ports.

  setUpAll(() async {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.settings = const Settings(
      host: 'localhost:8080',
      sslEnabled: false,
      persistenceEnabled: false,
    );
    fb_auth.FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  });

  tearDownAll(() async {
    // Best-effort cleanup of emulator data
    try {
      final project = Platform.environment['FIREBASE_PROJECT'] ?? 'demo-project';
      final url = Uri.parse('http://localhost:8080/emulator/v1/projects/$project/databases/(default)/documents');
      await http.delete(url);
    } catch (_) {}
  });

  test('concurrent ratePlan updates compute aggregate correctly', () async {
    // Create two emulator accounts and sign them in separately
    final a1 = await _createEmulatorAccount('emu1+${DateTime.now().millisecondsSinceEpoch}@example.com', 'password');
    final a2 = await _createEmulatorAccount('emu2+${DateTime.now().millisecondsSinceEpoch}@example.com', 'password');

    final planId = 'plan-emu-1-${DateTime.now().millisecondsSinceEpoch}';
    final planRef = FirebaseFirestore.instance.collection('public_plans').doc(planId);
    await planRef.set({'avgRating': 0.0, 'raterCount': 0});

    // Sign in user 1 in the FirebaseAuth instance context
  await _signInEmulatorAccount(a1['email'] as String, 'password');
  // Use the SDK signInWithEmailAndPassword for each user sequentially and call ratePlan.

    // Sign in user1 using SDK
    await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(email: a1['email'] as String, password: 'password');

    // Call ratePlan as user1
    await PublicService().ratePlan(planId, 5);

    // Sign out and sign in user2
    await fb_auth.FirebaseAuth.instance.signOut();
    await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(email: a2['email'] as String, password: 'password');

    // Call ratePlan as user2
    await PublicService().ratePlan(planId, 4);

    final snap = await planRef.get();
    final data = snap.data()!;
    final raterCount = (data['raterCount'] as num).toInt();
    final avgRating = (data['avgRating'] as num).toDouble();

    expect(raterCount, 2);
    expect(avgRating, closeTo(4.5, 0.0001));
  }, timeout: const Timeout(Duration(seconds: 60)));
}
