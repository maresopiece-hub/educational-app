/// MigrationRunner provides non-destructive migration of legacy StudyPlan data
/// stored in Hive. It converts legacy shapes (e.g. List<String> for questions
/// and subtopics) into the new object models (Question/Subtopic).

import 'package:hive/hive.dart';
import '../models/study_plan.dart';

class MigrationRunner {
  /// Migrates all StudyPlan entries in the 'studyPlans' box if needed.
  static Future<void> migrateStudyPlans() async {
    final box = Hive.box<StudyPlan>('studyPlans');
    for (var i = 0; i < box.length; i++) {
      final plan = box.getAt(i);
      if (plan == null) continue;
      bool changed = false;
      // Migrate legacy questions: if questions are stored as List<String>
      if (plan.questions.isNotEmpty && plan.questions.first is String) {
        final legacy = List<String>.from(plan.questions as List);
        plan.questions = legacy.map((s) => Question(
          type: plan.defaultQuestionType,
          prompt: s,
          choices: [],
          answer: '',
          explanation: ''
        )).toList();
        changed = true;
      }
      // Migrate legacy subtopics: if subtopics are stored as List<String>
      if (plan.subtopics.isNotEmpty && plan.subtopics.first is String) {
        final legacy = List<String>.from(plan.subtopics as List);
        plan.subtopics = legacy.map((s) => Subtopic(title: s)).toList();
        changed = true;
      } else {
        // Also migrate nested legacy fields in subtopics
        for (var st in plan.subtopics) {
          // Migrate legacy questions in subtopic
          if (st.questions.isNotEmpty && st.questions.first is String) {
            final legacy = List<String>.from(st.questions as List);
            st.questions = legacy.map((s) => Question(
              type: plan.defaultQuestionType,
              prompt: s,
              choices: [],
              answer: '',
              explanation: ''
            )).toList();
            changed = true;
          }
          // Additional migrations for explanations or notes can be added here if needed
        }
      }
      if (changed) {
        await plan.save();
      }
    }
  }
}
