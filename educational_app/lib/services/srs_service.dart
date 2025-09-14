import 'dart:math';
import '../models/flashcard.dart';
import '../models/lesson_plan.dart';

class SrsService {
  // Apply SM-2 algorithm update for a flashcard based on quality (0-5)
  void updateCard(Flashcard card, int quality) {
    // quality: 0-5
    if (quality < 0) quality = 0;
    if (quality > 5) quality = 5;
    if (quality < 3) {
      card.repetitions = 0;
      card.interval = 1;
    } else {
      card.repetitions += 1;
      if (card.repetitions == 1) {
        card.interval = 1;
      } else if (card.repetitions == 2) {
        card.interval = 6;
      } else {
        card.interval = (card.interval * card.ease).round();
      }
      // update ease
      card.ease = max(1.3, card.ease + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02)));
    }
    card.due = DateTime.now().add(Duration(days: max(1, card.interval)));
  }

  List<Flashcard> generateFromLesson(LessonPlan plan) {
    final cards = <Flashcard>[];
    for (final section in plan.sections) {
      // Create cards from keywords and questions
      for (final k in section.keywords) {
        cards.add(Flashcard(id: '${section.id}-kw-$k', front: k, back: section.explanation));
      }
      for (final q in section.questions) {
        cards.add(Flashcard(id: '${section.id}-q-${q.hashCode}', front: q.prompt, back: q.answer));
      }
    }
    return cards;
  }
}
