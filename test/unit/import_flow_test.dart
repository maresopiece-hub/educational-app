import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:typed_data';

import 'package:grade12_exam_prep_tutor/screens/home_dashboard_screen.dart';
import 'package:grade12_exam_prep_tutor/models/study_plan.dart';
import 'package:grade12_exam_prep_tutor/services/file_picker_service.dart';
import 'package:grade12_exam_prep_tutor/services/parser_service.dart';
import 'package:grade12_exam_prep_tutor/services/generator_service.dart';
import 'package:grade12_exam_prep_tutor/services/local_sync_service.dart';

class FakeFilePicker implements FilePickerService {
  final Uint8List bytes;
  final String name;
  FakeFilePicker(this.bytes, this.name);
  @override
  Future<PickedFile?> pickFile() async => PickedFile(bytes: bytes, name: name);
}

class FakeParser implements ParserService {
  final String out;
  FakeParser(this.out);
  @override
  Future<String> extractTextFromBytes(List<int> bytes) async => out;
}

class FakeGenerator implements GeneratorService {
  final List<StudyPlan> plans;
  FakeGenerator(this.plans);
  @override
  Future<List<StudyPlan>> generateFromText(String text) async => plans;
}

// Top-level fake to avoid declaring classes inside test bodies (which is invalid in Dart)
class FakeLocalSyncService extends LocalSyncService {
  FakeLocalSyncService() : super();
  @override
  void startConnectivityListener(String userId) {
    // no-op in tests
  }

  @override
  Future<int> pendingCount() async => 0;

  @override
  Future<void> syncPending(String userId) async {}
}

void main() {
  late final String tmpPath;
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('hive_test_');
    tmpPath = dir.path;
    Hive.init(tmpPath);
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(StudyPlanAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(FlashcardAdapter());
    await Hive.openBox<StudyPlan>('studyPlans');
  });

  tearDownAll(() async {
    final box = Hive.box<StudyPlan>('studyPlans');
    try {
      await box.clear().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('tearDownAll: box.clear timed out or failed: $e');
    }
    try {
      await box.close().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('tearDownAll: box.close timed out or failed: $e');
    }
    try {
      await Hive.close().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('tearDownAll: Hive.close timed out or failed: $e');
    }
    try {
      await Directory(tmpPath).delete(recursive: true);
    } catch (e) {
      debugPrint('tearDownAll: temp dir deletion failed: $e');
    }
  });

  testWidgets('import flow persists generated study plans', (tester) async {
    final fakeFile = FakeFilePicker(Uint8List.fromList([1,2,3]), 'test.pdf');
    final fakeParser = FakeParser('topic\nexplanation');
  final fakePlan = StudyPlan(topic: 'topic', subtopics: [Subtopic(title: 'a')], explanations: ['ex'], notes: [], questions: [], flashcards: []);
    final fakeGen = FakeGenerator([fakePlan]);

    // Use a fake sync service to avoid real connectivity listeners in tests
    final fakeSync = FakeLocalSyncService();

    await tester.pumpWidget(MaterialApp(home: HomeDashboard(testUserId: 'test', syncService: fakeSync, filePickerService: fakeFile, parserService: fakeParser, generatorService: fakeGen)));
    await tester.pumpAndSettle();

    // Tap the file upload icon (by tooltip)
    final uploadFinder = find.byTooltip('Import and generate study plans');
    expect(uploadFinder, findsOneWidget);
    await tester.tap(uploadFinder);
    await tester.pumpAndSettle();

    final box = Hive.box<StudyPlan>('studyPlans');
    expect(box.length, greaterThanOrEqualTo(1));
    final stored = box.getAt(0)!;
    expect(stored.topic, 'topic');
  });
}
