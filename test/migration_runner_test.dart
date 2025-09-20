import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../lib/models/study_plan.dart';
import '../lib/utils/migration_runner.dart';

// This test creates a legacy StudyPlan instance by first creating a valid StudyPlan,
// then overriding its questions and subtopics fields with legacy data types (List<String>).
// It then runs the migration and verifies that the fields have been converted to the new object models.

void main() async {
  // Set up a temporary Hive in-memory directory
  final directory = Directory.systemTemp.createTempSync();
  Hive.init(directory.path);
  
  // Register the StudyPlan adapter; assume it is defined in models/study_plan.dart
  Hive.registerAdapter(StudyPlanAdapter());
  
  // Open an in-memory box for testing
  final box = await Hive.openBox<StudyPlan>('studyPlans');

  group('MigrationRunner', () {
    test('migrates legacy questions and subtopics in StudyPlan', () async {
      // Create a valid StudyPlan instance with required fields
      final legacyPlan = StudyPlan(
        topic: 'Legacy Topic',
        questions: [],
        subtopics: [],
        defaultQuestionType: 'multiple'
      );

      // Override fields to simulate legacy data (List<String>)
      legacyPlan.questions = ['Legacy question'] as dynamic;
      legacyPlan.subtopics = ['Legacy subtopic'] as dynamic;

      // Add the legacy plan to the box
      await box.add(legacyPlan);

      // Run migration
      await MigrationRunner.migrateStudyPlans();

      // Retrieve migrated plan
      final migratedPlan = box.getAt(0)!;

      // Verify questions are now of type Question instead of String
      expect(migratedPlan.questions.isNotEmpty, true);
      expect(migratedPlan.questions.first.runtimeType.toString().toLowerCase(), contains('question'));

      // Verify subtopics are now of type Subtopic instead of String
      expect(migratedPlan.subtopics.isNotEmpty, true);
      expect(migratedPlan.subtopics.first.runtimeType.toString().toLowerCase(), contains('subtopic'));
    });
  });

  // Clean up
  tearDownAll(() async {
    await box.close();
    directory.deleteSync(recursive: true);
  });
}
