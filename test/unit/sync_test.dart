import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grade12_exam_prep_tutor/services/local_sync_service.dart';
import 'package:grade12_exam_prep_tutor/services/fake_notification_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class _FakeConnectivity implements Connectivity {
  final ConnectivityResult _result;
  _FakeConnectivity(this._result);

  @override
  Future<ConnectivityResult> checkConnectivity() async => _result;

  @override
  Stream<ConnectivityResult> get onConnectivityChanged async* {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('addPending and clearPending manage store', () async {
    SharedPreferences.setMockInitialValues({});
  final svc = LocalSyncService(connectivity: _FakeConnectivity(ConnectivityResult.wifi), notification: FakeNotificationService());
    final item = {'type': 'progress', 'data': {'completedPercent': 42}};
    await svc.addPending(item);
    final list = await svc.readAllPending();
    expect(list.length, 1);
    await svc.clearPending();
    final after = await svc.readAllPending();
    expect(after.length, 0);
  });

  test('syncPending records failure metric when Firestore unavailable', () async {
    SharedPreferences.setMockInitialValues({
      'local_pending_items': ['{"id":"t1","type":"progress","data":{},"retries":0}']
    });
  final svc = LocalSyncService(connectivity: _FakeConnectivity(ConnectivityResult.wifi), notification: FakeNotificationService());
    // Call syncPending with a fake userId; since Firestore isn't initialized
    // in unit tests, the method should write failure metric and not throw.
    await svc.syncPending('fake-user');
  final prefs = await SharedPreferences.getInstance();
  // In VM test environment Firestore plugin behavior varies; assert a metric was written (int present).
  final val = prefs.getInt('sync_errors');
  expect(val, isNotNull);
  expect(val, isA<int>());
  });
}
