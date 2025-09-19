import 'package:hive/hive.dart';

part 'study_plan.g.dart';

@HiveType(typeId: 0)
class StudyPlan extends HiveObject {
  @HiveField(0)
  String topic;

  @HiveField(1)
  List<String> subtopics;

  @HiveField(2)
  List<String> explanations;

  @HiveField(3)
  List<String> notes;

  @HiveField(4)
  List<String> questions;

  @HiveField(5)
  List<Flashcard> flashcards;

  StudyPlan({
    required this.topic,
    List<String>? subtopics,
    List<String>? explanations,
    List<String>? notes,
    List<String>? questions,
    List<Flashcard>? flashcards,
  })  : subtopics = subtopics ?? [],
        explanations = explanations ?? [],
        notes = notes ?? [],
        questions = questions ?? [],
        flashcards = flashcards ?? [];

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'subtopics': subtopics,
        'explanations': explanations,
        'notes': notes,
        'questions': questions,
        'flashcards': flashcards.map((f) => f.toJson()).toList(),
      };

  factory StudyPlan.fromJson(Map<String, dynamic> json) => StudyPlan(
        topic: json['topic'] as String? ?? 'Untitled',
        subtopics: List<String>.from(json['subtopics'] ?? []),
        explanations: List<String>.from(json['explanations'] ?? []),
        notes: List<String>.from(json['notes'] ?? []),
        questions: List<String>.from(json['questions'] ?? []),
        flashcards: (json['flashcards'] as List<dynamic>?)
                ?.map((e) => Flashcard.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
      );
}

@HiveType(typeId: 1)
class Flashcard extends HiveObject {
  @HiveField(0)
  String front;

  @HiveField(1)
  String back;

  Flashcard({required this.front, required this.back});

  Map<String, dynamic> toJson() => {'front': front, 'back': back};

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        front: json['front'] as String? ?? '',
        back: json['back'] as String? ?? '',
      );
}
