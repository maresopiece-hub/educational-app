import 'package:awesome_notifications/awesome_notifications.dart';

class ReminderService {
  static Future<void> scheduleReminder(String studyTime, String message) async {
    // Parse time, e.g., '19:00'
    List<String> timeParts = studyTime.split(':');
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'study_reminder',
        title: 'Study Time!',
        body: message,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
        repeats: true,
      ),
    );
  }

  static Future<void> requestPermission() async {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
}
