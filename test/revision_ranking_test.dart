import 'package:flutter_test/flutter_test.dart';
import 'package:grade12_exam_prep_tutor/models/study_plan.dart';
import 'package:grade12_exam_prep_tutor/utils/revision_utils.dart';

void main() {
  test('rankWeakest sorts by percent correct and aggregates attempts', () {
    final p1 = StudyPlan(topic: 'Algebra', questions: [Question(type: 'mcq', prompt: 'q1'), Question(type: 'mcq', prompt: 'q2')]);
    // simulate stats: first question 1/2 correct, second 0/1
    p1.questionAttempts['question:Algebra:0'] = 2;
    p1.questionCorrect['question:Algebra:0'] = 1;
    p1.questionAttempts['question:Algebra:1'] = 1;
    p1.questionCorrect['question:Algebra:1'] = 0;

    final p2 = StudyPlan(topic: 'Chemistry', questions: [Question(type: 'mcq', prompt: 'q1')]);
    p2.questionAttempts['question:Chemistry:0'] = 5;
    p2.questionCorrect['question:Chemistry:0'] = 4; // 80%

    final ranked = rankWeakest([p1, p2]);
    // weakest first should show Algebra entries before Chemistry
    expect(ranked.first.planTopic, 'Algebra');
    // Algebra percent correct: (1+0)/(2+1) = 33%
    expect((ranked.first.percentCorrect * 100).round(), 33);
  });
}
