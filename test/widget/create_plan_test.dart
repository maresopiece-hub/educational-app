import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:grade12_exam_prep_tutor/screens/plan_builder_screen.dart';
import 'package:grade12_exam_prep_tutor/models/study_plan.dart';

void main() {
  late final String tmpPath;
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hive_test_');
    tmpPath = dir.path;
    Hive.init(tmpPath);
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(StudyPlanAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(FlashcardAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SubtopicAdapter());
    await Hive.openBox<StudyPlan>('studyPlans');
  });

  tearDownAll(() async {
    final box = Hive.box<StudyPlan>('studyPlans');
    try { await box.clear(); } catch (_) {}
    try { await box.close(); } catch (_) {}
    try { await Hive.close(); } catch (_) {}
  });

  testWidgets('Create Plan saves to Hive', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlanBuilderScreen()));
    await tester.pumpAndSettle();

    // Enter subject and topic
    final subjectFinder = find.byType(TextFormField).first;
    await tester.enterText(subjectFinder, 'TestSubject');

    final titleFinder = find.byType(TextFormField).at(1);
    await tester.enterText(titleFinder, 'My Test Topic');

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    final box = Hive.box<StudyPlan>('studyPlans');
    expect(box.isNotEmpty, true);
    final p = box.getAt(0)!;
    expect(p.topic, 'My Test Topic');
    expect(p.subject, 'TestSubject');
  });
}
