import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:grade12_exam_prep_tutor/screens/home_dashboard_screen.dart';
import 'package:grade12_exam_prep_tutor/services/local_sync_service.dart';
import 'package:grade12_exam_prep_tutor/services/fake_notification_service.dart';

// A small fake service that behaves like a successful sync: clears pending on syncPending.
class _ClearingSyncService extends LocalSyncService {
  _ClearingSyncService() : super(connectivity: _ImmediateConnectivity(), notification: FakeNotificationService());

  @override
  Future<void> syncPending(String userId) async {
    // simulate clearing stored pending items
    await clearPending();
  }
}

class _ImmediateConnectivity implements Connectivity {
  @override
  Future<ConnectivityResult> checkConnectivity() async => ConnectivityResult.wifi;

  @override
  Stream<ConnectivityResult> get onConnectivityChanged async* {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AppBar sync button triggers syncPending and updates pending UI', (tester) async {
    SharedPreferences.setMockInitialValues({
      'local_pending_items': ['{"id":"t1","type":"progress","data":{},"retries":0}']
    });

  final svc = _ClearingSyncService();

    await tester.pumpWidget(MaterialApp(home: HomeDashboard(testUserId: 'test-uid', syncService: svc)));
    await tester.pumpAndSettle();

    // Initially, the pending count is shown
    expect(find.textContaining('Pending sync'), findsOneWidget);

    // Tap the sync button in the AppBar
    final syncButton = find.byIcon(Icons.sync);
    expect(syncButton, findsOneWidget);
    await tester.tap(syncButton);
    await tester.pumpAndSettle();

  // After sync completes, the service should report zero pending items
  final remaining = await svc.pendingCount();
  expect(remaining, 0);
  });
}
