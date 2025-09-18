import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grade12_exam_prep_tutor/services/local_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('addPending and clearPending manage store', () async {
    SharedPreferences.setMockInitialValues({});
    final svc = LocalSyncService();
    final item = {'type': 'progress', 'data': {'completedPercent': 42}};
    await svc.addPending(item);
    final list = await svc.readAllPending();
    expect(list.length, 1);
    await svc.clearPending();
    final after = await svc.readAllPending();
    expect(after.length, 0);
  });
}
