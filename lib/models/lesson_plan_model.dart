class LessonPlanSection {
  String explanation;
  List<String> examples;
  List<Map<String, dynamic>> questions;
  bool complete;
  String? note;

  LessonPlanSection({
    required this.explanation,
    required this.examples,
    required this.questions,
    required this.complete,
    this.note,
  });

  factory LessonPlanSection.fromMap(Map<String, dynamic> map) {
    return LessonPlanSection(
      explanation: map['explanation'] ?? '',
      examples: List<String>.from(map['examples'] ?? []),
      questions: List<Map<String, dynamic>>.from(map['questions'] ?? []),
      complete: map['complete'] ?? false,
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'explanation': explanation,
      'examples': examples,
      'questions': questions,
      'complete': complete,
      if (note != null) 'note': note,
    };
  }
}

class LessonPlan {
  String title;
  List<LessonPlanSection> sections;
  bool isPublic;

  LessonPlan({
    required this.title,
    required this.sections,
    this.isPublic = false,
  });

  factory LessonPlan.fromMap(Map<String, dynamic> map) {
    return LessonPlan(
      title: map['title'] ?? '',
      sections: (map['sections'] as List<dynamic>? ?? [])
          .map((e) => LessonPlanSection.fromMap(e as Map<String, dynamic>))
          .toList(),
      isPublic: map['isPublic'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'sections': sections.map((e) => e.toMap()).toList(),
      'isPublic': isPublic,
    };
  }
}
