import 'package:flutter_test/flutter_test.dart';

class FakeFirestoreService {
  final Map<String, List<Map<String, dynamic>>> _store = {};

  Future<void> saveUserPlan(String userId, Map<String, dynamic> plan) async {
    _store.putIfAbsent(userId, () => []).add(plan);
  }

  Future<List<Map<String, dynamic>>> getUserPlans(String userId) async {
    return _store[userId] ?? [];
  }
}

void main() {
  test('saveUserPlan and getUserPlans work', () async {
    final svc = FakeFirestoreService();
    final plan = {'title': 'Study Math', 'duration': 60};
    await svc.saveUserPlan('user1', plan);
    final plans = await svc.getUserPlans('user1');
    expect(plans, hasLength(1));
    expect(plans.first['title'], 'Study Math');
  });
}
