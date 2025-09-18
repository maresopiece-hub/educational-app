
import 'notification_service.dart';

class FakeNotificationService implements NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<void> showSimpleNotification(int id, String title, String body) async {}

  @override
  Future<void> scheduleNudge(dynamic context, int progressThreshold, String msg) async {}
}
