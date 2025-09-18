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
      final planRef = _firestore.collection('public_plans').doc(planId);
      final ratingsRef = planRef.collection('ratings');

      await _firestore.runTransaction((tx) async {
        final planSnap = await tx.get(planRef);
        if (!planSnap.exists) throw StateError('Plan not found');

        final data = planSnap.data()!;
        double oldAvg = (data['avgRating'] as num?)?.toDouble() ?? 0.0;
        int oldCount = (data['raterCount'] as num?)?.toInt() ?? 0;

        // Check for existing rating by this user
        final existingQuery = await ratingsRef.where('userId', isEqualTo: user.uid).limit(1).get();
        if (existingQuery.docs.isNotEmpty) {
          final doc = existingQuery.docs.first;
          final oldStars = (doc.data()['stars'] as num?)?.toInt() ?? 0;
          // Update rating doc
          tx.update(doc.reference, {'stars': stars, 'updatedAt': FieldValue.serverTimestamp()});
          // Recalculate average: (oldAvg*count - oldStars + stars) / count
          final newAvg = oldCount > 0 ? ((oldAvg * oldCount) - oldStars + stars) / oldCount : stars.toDouble();
          tx.update(planRef, {'avgRating': newAvg, 'raterCount': oldCount});
        } else {
          // Create new rating
          final newDoc = ratingsRef.doc();
          tx.set(newDoc, {'userId': user.uid, 'stars': stars, 'createdAt': FieldValue.serverTimestamp()});
          // Recalculate average: (oldAvg*count + stars) / (count + 1)
          final newCount = oldCount + 1;
          final newAvg = ((oldAvg * oldCount) + stars) / newCount;
          tx.update(planRef, {'avgRating': newAvg, 'raterCount': newCount});
        }
      });
    }
  }
}
