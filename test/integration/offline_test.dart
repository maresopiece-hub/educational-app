import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grade12_exam_prep_tutor/services/local_sync_service.dart';

void main() {
  test('save pending locally and read back', () async {
    // Ensure bindings are initialized for plugin calls and mock prefs
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final svc = LocalSyncService();
    final item = {'type': 'plan', 'data': {'title': 'Test Plan', 'createdAt': DateTime.now().toIso8601String()}};
    await svc.addPending(item);
  final pending = await svc.readAllPending();
  expect(pending.isNotEmpty, true);
  // Clean up
  await svc.clearPending();
  final after = await svc.readAllPending();
  expect(after.isEmpty, true);
  });
}
