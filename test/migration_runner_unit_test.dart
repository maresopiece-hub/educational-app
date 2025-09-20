import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../lib/models/study_plan.dart';
import '../lib/utils/migration_runner.dart';

void main() {
  group('MigrationRunner unit', () {
    late Directory tmp;
    setUp(() {
      tmp = Directory.systemTemp.createTempSync('hive_mig_test');
      Hive.init(tmp.path);
      Hive.registerAdapter(StudyPlanAdapter());
    });

    tearDown(() async {
      try {
        await Hive.close();
      } catch (_) {}
      try {
        tmp.deleteSync(recursive: true);
      } catch (_) {}
    });

    test('migrates legacy list<string> question and subtopic shapes', () async {
      final box = await Hive.openBox<StudyPlan>('studyPlans');
      final plan = StudyPlan(topic: 'T', questions: [], subtopics: [], defaultQuestionType: 'mcq');
      // inject legacy shapes
      (plan.toJson()..remove('questions'));
      // simulate legacy by assigning dynamic lists
      plan.questions = ['legacy q1'] as dynamic;
      plan.subtopics = ['legacy sub'] as dynamic;
      await box.add(plan);

      await MigrationRunner.migrateStudyPlans();

      final migrated = box.getAt(0)!;
      expect(migrated.questions.isNotEmpty, true);
      expect(migrated.questions.first.prompt, 'legacy q1');
      expect(migrated.subtopics.isNotEmpty, true);
      expect(migrated.subtopics.first.title, 'legacy sub');

      await box.close();
    });
  });
}
