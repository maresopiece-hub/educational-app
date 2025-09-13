import 'package:flutter_test/flutter_test.dart';
import 'package:educational_app/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('DatabaseService activity log and progress', () {
    const userId = 'test_user@example.com';

    setUpAll(() async {
      // Initialize ffi for sqflite in tests
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      // Create a fresh in-memory DB for each test to ensure isolation
      await DatabaseService.instance.initInMemory();
    });

    test('consecutive active days calculation', () async {
      final now = DateTime.now();
      // log activities for today, yesterday, and day before yesterday
      await DatabaseService.instance.logActivity(userId, 'study', at: now);
      await DatabaseService.instance.logActivity(userId, 'study', at: now.subtract(Duration(days: 1)));
      await DatabaseService.instance.logActivity(userId, 'study', at: now.subtract(Duration(days: 2)));

      final streak = await DatabaseService.instance.getConsecutiveActiveDays(userId);
      expect(streak, 3);
    });

    test('non-consecutive active days stops streak', () async {
      final now = DateTime.now();
      // log for today and 2 days ago (skip yesterday)
      await DatabaseService.instance.logActivity(userId, 'study', at: now);
      await DatabaseService.instance.logActivity(userId, 'study', at: now.subtract(Duration(days: 2)));

      final streak = await DatabaseService.instance.getConsecutiveActiveDays(userId);
      expect(streak, 1);
    });

    test('overall progress from flashcards and plans', () async {
      final db = await DatabaseService.instance.database;
      // insert some flashcards
      await db.insert('flashcards', {'userId': userId, 'front': 'Q1', 'back': 'A1', 'completed': 1});
      await db.insert('flashcards', {'userId': userId, 'front': 'Q2', 'back': 'A2', 'completed': 0});
      // insert study plans with progress
      await db.insert('study_plans', {'userId': userId, 'pdfName': 'doc', 'plan': '{}', 'progress': 50});
      await db.insert('study_plans', {'userId': userId, 'pdfName': 'doc2', 'plan': '{}', 'progress': 100});

      // Compute values similar to ProgressWidget logic
      final flashcards = await DatabaseService.instance.getFlashcards(userId);
      final plansRes = await db.query('study_plans', where: 'userId = ?', whereArgs: [userId]);
      final totalFlash = flashcards.length;
      final completedFlash = flashcards.where((f) => (f['completed'] as int? ?? 0) > 0).length;
      final flashProgress = totalFlash > 0 ? (completedFlash / totalFlash) : 0.0;

      final total = plansRes.fold<int>(0, (p, e) => p + (e['progress'] as int? ?? 0));
      final planProgress = total / (plansRes.length * 100);
      final overall = (planProgress + flashProgress) / 2;

      expect(flashProgress, 0.5);
      expect(planProgress, closeTo(0.75, 0.001));
      expect(overall, closeTo((0.75 + 0.5) / 2, 0.001));
    });
  });
}
