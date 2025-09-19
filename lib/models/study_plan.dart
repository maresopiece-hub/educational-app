import 'package:hive/hive.dart';

part 'study_plan.g.dart';

@HiveType(typeId: 3)
class Question {
      @HiveField(0)
      String type; // 'mcq', 'tf', 'fill', 'essay'
      @HiveField(1)
      String prompt;
      @HiveField(2)
      List<String> choices;
      @HiveField(3)
      String answer;
      @HiveField(4)
      String explanation;

      Question({required this.type, required this.prompt, List<String>? choices, String? answer, String? explanation})
                  : choices = choices ?? [],
                        answer = answer ?? '',
                        explanation = explanation ?? '';

      Map<String, dynamic> toJson() => {'type': type, 'prompt': prompt, 'choices': choices, 'answer': answer, 'explanation': explanation};
      factory Question.fromJson(Map<String, dynamic> json) => Question(type: json['type'] as String? ?? 'mcq', prompt: json['prompt'] as String? ?? '', choices: List<String>.from(json['choices'] ?? []), answer: json['answer'] as String? ?? '', explanation: json['explanation'] as String? ?? '');
}

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
      List<Question> questions;

      @HiveField(6)
      List<Flashcard> flashcards;
  
            @HiveField(7)
            Map<String, int> completedItems;

            @HiveField(8)
            String defaultQuestionType;
            
            @HiveField(9)
            Map<String, int> questionAttempts;

            @HiveField(10)
            Map<String, int> questionCorrect;

            @HiveField(11)
            bool favorite;
  

            StudyPlan({
                  required this.topic,
                  String? subject,
                  List<Subtopic>? subtopics,
                  List<String>? explanations,
                  List<String>? notes,
                  List<Question>? questions,
                  List<Flashcard>? flashcards,
                              Map<String, int>? completedItems, // itemId -> timestamp(ms since epoch)
                              String? defaultQuestionType,
                              Map<String, int>? questionAttempts,
                              Map<String, int>? questionCorrect,
                              bool? favorite,
                              })  : subject = subject ?? 'General',
                                                subtopics = subtopics ?? [],
                                                explanations = explanations ?? [],
                                                notes = notes ?? [],
                                                questions = questions ?? [],
                                                flashcards = flashcards ?? [],
                                                completedItems = completedItems ?? {},
                                                defaultQuestionType = defaultQuestionType ?? 'mcq',
                                                questionAttempts = questionAttempts ?? {},
                                                questionCorrect = questionCorrect ?? {},
                                                favorite = favorite ?? false;

      Map<String, dynamic> toJson() => {
                                          'subject': subject,
                                          'topic': topic,
                                          'subtopics': subtopics.map((s) => s.toJson()).toList(),
                        'explanations': explanations,
                        'notes': notes,
                              'questions': questions.map((q) => q.toJson()).toList(),
                                                      'flashcards': flashcards.map((f) => f.toJson()).toList(),
                                                      'completedItems': completedItems,
                                                            'defaultQuestionType': defaultQuestionType,
                                                            'questionAttempts': questionAttempts,
                                                            'questionCorrect': questionCorrect,
                                                            'favorite': favorite,
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
      questions: (json['questions'] as List<dynamic>?)?.map((e) => Question.fromJson(Map<String, dynamic>.from(e as Map))).toList() ?? [],
        flashcards: (json['flashcards'] as List<dynamic>?)
                ?.map((e) => Flashcard.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
                                          completedItems: (json['completedItems'] as Map?)?.cast<String, int>() ?? {},
                                          defaultQuestionType: json['defaultQuestionType'] as String? ?? 'mcq',
                                          questionAttempts: (json['questionAttempts'] as Map?)?.cast<String, int>() ?? {},
                                          questionCorrect: (json['questionCorrect'] as Map?)?.cast<String, int>() ?? {},
                                          favorite: json['favorite'] as bool? ?? false,
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
      List<Question> questions;

  @HiveField(4)
  List<Flashcard> flashcards;

      @HiveField(5)
      List<Subtopic> subtopics; // nested subtopics (supports up to N levels)

      Subtopic({required this.title, List<String>? explanations, List<String>? notes, List<Question>? questions, List<Flashcard>? flashcards, List<Subtopic>? subtopics})
                  : explanations = explanations ?? [],
                        notes = notes ?? [],
                        questions = questions ?? [],
                        flashcards = flashcards ?? [],
                        subtopics = subtopics ?? [];

  Map<String, dynamic> toJson() => {
        'title': title,
        'explanations': explanations,
        'notes': notes,
        'questions': questions.map((q) => q.toJson()).toList(),
        'flashcards': flashcards.map((f) => f.toJson()).toList(),
        'subtopics': subtopics.map((s) => s.toJson()).toList(),
      };

  factory Subtopic.fromJson(Map<String, dynamic> json) => Subtopic(
        title: json['title'] as String? ?? 'Untitled',
        explanations: List<String>.from(json['explanations'] ?? []),
        notes: List<String>.from(json['notes'] ?? []),
        questions: (json['questions'] as List<dynamic>?)?.map((e) => Question.fromJson(Map<String, dynamic>.from(e as Map))).toList() ?? [],
        flashcards: (json['flashcards'] as List<dynamic>?)
                ?.map((e) => Flashcard.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
      subtopics: (json['subtopics'] as List<dynamic>?)
            ?.map((e) => Subtopic.fromJson(Map<String, dynamic>.from(e as Map)))
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
