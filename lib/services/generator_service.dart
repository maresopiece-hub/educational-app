import '../models/study_plan.dart';
import '../utils/lesson_plan_generator.dart';

abstract class GeneratorService {
  Future<List<StudyPlan>> generateFromText(String text);
}

class DefaultGeneratorService implements GeneratorService {
  @override
  Future<List<StudyPlan>> generateFromText(String text) => LessonPlanGenerator.generateFromText(text);
}
