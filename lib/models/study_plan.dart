import 'package:hive/hive.dart';

part 'study_plan.g.dart';

@HiveType(typeId: 0)
class StudyPlan extends HiveObject {
      @HiveField(0)
      String subject;
      @HiveField(1)
      String topic;

      @HiveField(2)
      List<Subtopic> subtopics;

      @HiveField(3)
      List<String> explanations;

      @HiveField(4)
      List<String> notes;

      @HiveField(5)
      List<String> questions;

      @HiveField(6)
      List<Flashcard> flashcards;

            StudyPlan({
                  required this.topic,
                  String? subject,
                  List<Subtopic>? subtopics,
                  List<String>? explanations,
                  List<String>? notes,
                  List<String>? questions,
                  List<Flashcard>? flashcards,
            })  : subject = subject ?? 'General',
                              subtopics = subtopics ?? [],
                              explanations = explanations ?? [],
                              notes = notes ?? [],
                              questions = questions ?? [],
                              flashcards = flashcards ?? [];

      Map<String, dynamic> toJson() => {
                                          'subject': subject,
                                          'topic': topic,
                                          'subtopics': subtopics.map((s) => s.toJson()).toList(),
                        'explanations': explanations,
                        'notes': notes,
                        'questions': questions,
                        'flashcards': flashcards.map((f) => f.toJson()).toList(),
                  };

  factory StudyPlan.fromJson(Map<String, dynamic> json) => StudyPlan(
        subject: json['subject'] as String? ?? 'General',
        topic: json['topic'] as String? ?? 'Untitled',
        subtopics: (json['subtopics'] as List<dynamic>?)
                ?.map((e) => Subtopic.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
        explanations: List<String>.from(json['explanations'] ?? []),
        notes: List<String>.from(json['notes'] ?? []),
        questions: List<String>.from(json['questions'] ?? []),
        flashcards: (json['flashcards'] as List<dynamic>?)
                ?.map((e) => Flashcard.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
      );
}

@HiveType(typeId: 2)
class Subtopic {
  @HiveField(0)
  String title;

  @HiveField(1)
  List<String> explanations;

  @HiveField(2)
  List<String> notes;

  @HiveField(3)
  List<String> questions;

  @HiveField(4)
  List<Flashcard> flashcards;

  Subtopic({required this.title, List<String>? explanations, List<String>? notes, List<String>? questions, List<Flashcard>? flashcards})
      : explanations = explanations ?? [],
        notes = notes ?? [],
        questions = questions ?? [],
        flashcards = flashcards ?? [];

  Map<String, dynamic> toJson() => {
        'title': title,
        'explanations': explanations,
        'notes': notes,
        'questions': questions,
        'flashcards': flashcards.map((f) => f.toJson()).toList(),
      };

  factory Subtopic.fromJson(Map<String, dynamic> json) => Subtopic(
        title: json['title'] as String? ?? 'Untitled',
        explanations: List<String>.from(json['explanations'] ?? []),
        notes: List<String>.from(json['notes'] ?? []),
        questions: List<String>.from(json['questions'] ?? []),
        flashcards: (json['flashcards'] as List<dynamic>?)
                ?.map((e) => Flashcard.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
      );
}
// Flashcard remains a top-level class

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
