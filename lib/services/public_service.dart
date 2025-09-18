import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PublicService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> uploadPublicPlan(Map<String, dynamic> plan, String title, String topic) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('public_plans').add({
        'title': title,
        'topic': topic,
        'creator': user.uid,
        'creatorName': user.displayName ?? 'Anonymous',
        'plan': plan,
        'ratings': [], // List of {userId: stars}
        'avgRating': 0.0,
        'raterCount': 0,
      });
    }
  }

  Stream<List<Map<String, dynamic>>> getTopPlans() {
    return _firestore.collection('public_plans')
        .orderBy('avgRating', descending: true)
        .orderBy('raterCount', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> ratePlan(String planId, int stars) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Update ratings array, recalc avg
      // Logic to add/update rating, update counts
    }
  }
}
