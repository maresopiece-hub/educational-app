import 'package:uuid/uuid.dart';

class LessonPlan {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<LessonSection> sections;

  LessonPlan({String? id, required this.title, DateTime? createdAt, required this.sections})
      : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
}

class LessonSection {
  final String id;
  final String title;
  final String explanation;
  final List<String> examples;
  final List<Question> questions;
  final List<String> keywords;
  final double completeness;

  LessonSection({required this.id, required this.title, required this.explanation, required this.examples, required this.questions, required this.keywords, required this.completeness});
}

enum QuestionType { mcq, shortAnswer, fillIn }

class Question {
  final String id;
  final QuestionType type;
  final String prompt;
  final String answer;
  final List<String> options; // for MCQ
  final String rationale; // explanation for answer

  Question({String? id, required this.type, required this.prompt, required this.answer, this.options = const [], required this.rationale}) : id = id ?? const Uuid().v4();
}
