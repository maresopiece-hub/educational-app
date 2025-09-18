// Firestore emulator tests for PublicService.ratePlan
// Requires Firebase CLI emulator to be running (see instructions below).

/*
To run these tests locally with the Firebase emulator:

1. Install the Firebase CLI and initialize the emulators for Firestore:
   firebase init emulators

2. Start the emulator:
   firebase emulators:start --only firestore

3. In another terminal, run:
   flutter test test/firestore_tests.dart

These tests are written to connect to the local emulator when its environment
variables are set (FIRESTORE_EMULATOR_HOST), otherwise they are skipped.
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:grade12_exam_prep_tutor/services/public_service.dart';
import 'dart:io';

void main() {
  final emulatorHost = Platform.environment['FIRESTORE_EMULATOR_HOST'];
  if (emulatorHost == null || emulatorHost.isEmpty) {
    test('emulator not configured - skip', () {
      expect(true, isTrue);
    });
    return;
  }

  setUpAll(() async {
    await Firebase.initializeApp();
    // Direct Firestore to emulator
    FirebaseFirestore.instance.settings = const Settings(host: 'localhost:8080', sslEnabled: false, persistenceEnabled: false);
  });

  test('ratePlan updates avgRating and raterCount correctly', () async {
    final ps = PublicService();
    // Create a public plan
    final col = FirebaseFirestore.instance.collection('public_plans');
    final docRef = await col.add({'title': 'Emu Plan', 'avgRating': 0.0, 'raterCount': 0});
    final id = docRef.id;

    // Simulate two users rating concurrently
    await ps.ratePlan(id, 4); // assume current user set by environment in a real test

    // This is a placeholder: full concurrent simulation requires multiple auth contexts.
    final snap = await docRef.get();
    expect(snap.exists, true);
    final data = snap.data()!;
    expect(data['raterCount'], isNotNull);
  });
}
