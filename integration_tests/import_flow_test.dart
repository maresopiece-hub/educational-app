// Integration test: import_flow_test
// This test is intended to run on a device/emulator (not in the Dart VM).
// It performs an end-to-end check of the lesson-plan generation + persistence.
//
// Notes for running:
// 1. Start Firebase emulators if you plan to exercise networked code:
//    firebase emulators:start --only auth,firestore
// 2. Run this test on a connected device or emulator:
//    flutter test integration_tests/import_flow_test.dart
//
// The test below runs a self-contained flow that calls the generator on a
// sample text and verifies that StudyPlans are saved to Hive. To adapt it to
// a true file-pick + parser flow, replace the generator input with parsed
// bytes (using ParserService) and/or drive the UI to tap the import button.

import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:grade12_exam_prep_tutor/models/study_plan.dart';
import 'package:grade12_exam_prep_tutor/utils/lesson_plan_generator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('generator -> Hive persistence (integration)', (tester) async {
    // Initialize Hive on the device filesystem
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(StudyPlanAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(FlashcardAdapter());
    final box = await Hive.openBox<StudyPlan>('studyPlans');

    // Sample text that the generator can consume
    final sample = 'Chapter 1\nSimple Topic\nThis is an explanatory paragraph about the topic.';
    final plans = await LessonPlanGenerator.generateFromText(sample);

    // Persist generated plans
    for (final p in plans) await box.add(p);

    expect(box.isNotEmpty, true);

    // Cleanup
    await box.clear();
    await box.close();
  });
}
