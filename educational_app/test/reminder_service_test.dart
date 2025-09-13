import 'package:flutter_test/flutter_test.dart';
import 'package:educational_app/services/reminder_service.dart';

void main() {
  group('ReminderService', () {
    test('schedules reminder without error', () async {
      // This is a logic test; actual notification scheduling can't be tested in unit tests.
      // But we can check that the static method exists and runs without error.
      await ReminderService.scheduleReminder('19:00', 'Test Reminder');
      expect(true, isTrue); // If no exceptions, test passes.
    });
  });
}
