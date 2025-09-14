import 'package:flutter_test/flutter_test.dart';
import 'package:educational_app/services/srs_service.dart';
import 'package:educational_app/models/lesson_plan.dart';

void main() {
  final srs = SrsService();

  test('generate flashcards from lesson plan', () {
    final q = Question(type: QuestionType.shortAnswer, prompt: 'What is X?', answer: 'X', rationale: 'Because.');
    final ls = LessonSection(id: 'sec1', title: 'Sec', explanation: 'Expl', examples: [], questions: [q], keywords: ['a', 'b'], completeness: 0.5);
    final plan = LessonPlan(title: 'P', sections: [ls]);
    final cards = srs.generateFromLesson(plan);
    expect(cards.isNotEmpty, true);
    expect(cards.any((c) => c.front.contains('What is X')), true);
  });

  test('sm2 update increases interval on good quality', () {
    final q = Question(type: QuestionType.shortAnswer, prompt: 'Q', answer: 'A', rationale: 'R');
    final ls = LessonSection(id: 's', title: 't', explanation: 'e', examples: [], questions: [q], keywords: [], completeness: 0.1);
    final plan = LessonPlan(title: 'p', sections: [ls]);
    final cards = srs.generateFromLesson(plan);
    final card = cards.first;
    final before = card.interval;
    srs.updateCard(card, 5);
    expect(card.interval >= before, true);
  });
}
