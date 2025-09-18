import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:grade12_exam_prep_tutor/screens/home_dashboard_screen.dart';
import 'package:grade12_exam_prep_tutor/services/local_sync_service.dart';
import 'package:grade12_exam_prep_tutor/services/fake_notification_service.dart';

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

    final svc = LocalSyncService(connectivity: _ImmediateConnectivity(), notification: FakeNotificationService());

    await tester.pumpWidget(MaterialApp(home: HomeDashboard(testUserId: 'test-uid', syncService: svc)));
    await tester.pumpAndSettle();

    // Initially, the pending count is shown
    expect(find.textContaining('Pending sync'), findsOneWidget);

    // Tap the sync button in the AppBar
    final syncButton = find.byIcon(Icons.sync);
    expect(syncButton, findsOneWidget);
    await tester.tap(syncButton);
    await tester.pumpAndSettle();

    // After sync completes, the pending UI should no longer show pending > 0
    expect(find.textContaining('Pending sync'), findsNothing);
  });
}
