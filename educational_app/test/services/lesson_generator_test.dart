import 'package:flutter_test/flutter_test.dart';
import 'package:educational_app/services/lesson_generator_service.dart';
import 'package:educational_app/models/section_model.dart';

void main() {
  final gen = LessonGeneratorService();

  test('generate lesson from single section (happy path)', () {
    final section = SectionModel(id: 's1', title: 'Topic 1', text: 'Pythagoras theorem states that a^2 + b^2 = c^2. Use for right triangles. Example: 3,4,5.', keywords: ['pythagoras', 'triangle', 'hypotenuse'], completeness: 0.8);
    final plan = gen.generateFromSections([section], title: 'Test Plan');
    expect(plan.sections.length, 1);
    final sec = plan.sections.first;
    expect(sec.questions.length >= 3, true);
    expect(sec.examples.length >= 1, true);
    expect(sec.keywords.isNotEmpty, true);
  });

  test('short section handles gracefully', () {
    final section = SectionModel(id: 's2', title: 'Tiny', text: 'Definition: energy.', keywords: [], completeness: 0.2);
    final plan = gen.generateFromSections([section]);
    expect(plan.sections.length, 1);
    final sec = plan.sections.first;
    // Should produce at least one question
    expect(sec.questions.isNotEmpty, true);
  });

  test('deterministic output for same input', () {
    final section = SectionModel(id: 's3', title: 'Det', text: 'Photosynthesis converts light to chemical energy. Chlorophyll absorbs light.', keywords: ['photosynthesis', 'chlorophyll'], completeness: 0.6);
    final a = gen.generateFromSections([section]);
    final b = gen.generateFromSections([section]);
    // Compare serialized-ish properties to ensure deterministic behavior
    expect(a.sections.first.explanation, b.sections.first.explanation);
    expect(a.sections.first.questions.map((q) => q.prompt).toList(), b.sections.first.questions.map((q) => q.prompt).toList());
  });
}
