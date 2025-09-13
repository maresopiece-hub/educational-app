import 'package:flutter_test/flutter_test.dart';
import 'package:educational_app/services/tutor_generator.dart';

void main() {
  group('TutorGenerator', () {
    test('generates flashcards from section', () {
      final section = 'Photosynthesis is the process by which green plants convert sunlight into energy.';
      final flashcards = TutorGenerator().generateFlashcards(section);
      expect(flashcards, isA<List<Map<String, dynamic>>>());
      expect(flashcards.isNotEmpty, true);
    });

    test('generates questions from section', () {
      final section = 'The mitochondria is the powerhouse of the cell.';
      final questions = TutorGenerator().generateQuestions(section);
      expect(questions, isA<List<Map<String, dynamic>>>());
      expect(questions.isNotEmpty, true);
    });
  });
}
