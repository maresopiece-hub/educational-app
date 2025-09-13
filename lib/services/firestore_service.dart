import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserPlan(String userId, Map<String, dynamic> plan) async {
    await _db.collection('users').doc(userId).collection('plans').add(plan);
  }

  Future<List<Map<String, dynamic>>> getUserPlans(String userId) async {
    final snapshot = await _db.collection('users').doc(userId).collection('plans').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> saveUserProgress(String userId, Map<String, dynamic> progress) async {
    await _db.collection('users').doc(userId).collection('progress').add(progress);
  }

  Future<List<Map<String, dynamic>>> getUserProgress(String userId) async {
    final snapshot = await _db.collection('users').doc(userId).collection('progress').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
