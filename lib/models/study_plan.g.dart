// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudyPlanAdapter extends TypeAdapter<StudyPlan> {
  @override
  final int typeId = 0;

  @override
  StudyPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    // Defensive deserialization: the on-disk layout may be from an older
    // version where field ids or types differed. Instead of trusting the
    // numeric fields strictly, probe `fields` for likely values.

    // Helper to get a String-valued field, falling back to searching values.
    String _stringFieldOrFirstString(int key, String fallback) {
      final v = fields[key];
      if (v is String) return v;
      for (final val in fields.values) {
        if (val is String) return val;
      }
      return fallback;
    }

    // Helper to get an optional String (subject).
    String? _optionalStringField(int key) {
      final v = fields[key];
      if (v == null) return null;
      if (v is String) return v;
      return null;
    }

    // Detect raw subtopics: either at the expected key or anywhere in the
    // fields map as a List whose elements are strings or subtopic-like.
    dynamic _findRawSubtopics() {
      final candidate = fields[2];
      if (candidate != null) return candidate;
      for (final val in fields.values) {
        if (val is List) return val;
      }
      return null;
    }

    // Resolve rawSubtopics into List<Subtopic> safely.
    List<Subtopic>? _coerceSubtopics(dynamic raw) {
      if (raw == null) return <Subtopic>[];
      if (raw is List<Subtopic>) return raw;
      if (raw is List) {
        try {
          return raw.map<Subtopic>((e) {
            if (e is Subtopic) return e;
            if (e is String) return Subtopic(title: e);
            if (e is Map) {
              return Subtopic(
                title: (e['title'] ?? '') as String,
                explanations: (e['explanations'] as List?)?.cast<String>() ?? <String>[],
                notes: (e['notes'] as List?)?.cast<String>() ?? <String>[],
                questions: (e['questions'] as List?)?.map<Question>((qq) {
                      if (qq is Question) return qq;
                      if (qq is String) return Question(type: 'mcq', prompt: qq);
                      if (qq is Map) return Question.fromJson(Map<String, dynamic>.from(qq));
                      return Question(type: 'mcq', prompt: qq?.toString() ?? '');
                    }).toList() ?? <Question>[],
                flashcards: (e['flashcards'] as List?)?.cast<Flashcard>() ?? <Flashcard>[],
              );
            }
            return Subtopic(title: e?.toString() ?? '');
          }).toList();
        } catch (err) {
          return <Subtopic>[];
        }
      }
      return <Subtopic>[];
    }

    final topic = _stringFieldOrFirstString(1, 'Untitled');
    final subject = _optionalStringField(0) ?? 'General';
    final rawSubtopics = _findRawSubtopics();
    final subtopics = _coerceSubtopics(rawSubtopics);

    // Other list fields — attempt to cast, but be resilient if they are null.
    final explanations = (fields[3] as List?)?.cast<String>() ?? <String>[];
      final notes = (fields[4] as List?)?.cast<String>() ?? <String>[];
      final questions = (fields[5] as List?)?.cast<Question>() ?? <Question>[];
      final flashcards = (fields[6] as List?)?.cast<Flashcard>() ?? <Flashcard>[];
  final completedItems = (fields[7] as Map?)?.cast<String, int>() ?? <String, int>{};
    final defaultQuestionType = (fields[8] as String?) ?? 'mcq';

    return StudyPlan(
      topic: topic,
      subject: subject,
      subtopics: subtopics,
      explanations: explanations,
      notes: notes,
      questions: questions,
      flashcards: flashcards,
      completedItems: completedItems,
      defaultQuestionType: defaultQuestionType,
    );
  }

  @override
  void write(BinaryWriter writer, StudyPlan obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.subject)
      ..writeByte(1)
      ..write(obj.topic)
      ..writeByte(2)
      ..write(obj.subtopics)
      ..writeByte(3)
      ..write(obj.explanations)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.questions)
      ..writeByte(6)
      ..write(obj.flashcards)
      ..writeByte(7)
      ..write(obj.completedItems);
      writer
      ..writeByte(8)
      ..write(obj.defaultQuestionType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuestionAdapter extends TypeAdapter<Question> {
  @override
  final int typeId = 3;

  @override
  Question read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{ for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read() };
    return Question(
      type: fields[0] as String,
      prompt: fields[1] as String,
      choices: (fields[2] as List?)?.cast<String>() ?? <String>[],
      answer: fields[3] as String,
      explanation: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Question obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.prompt)
      ..writeByte(2)
      ..write(obj.choices)
      ..writeByte(3)
      ..write(obj.answer)
      ..writeByte(4)
      ..write(obj.explanation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is QuestionAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class SubtopicAdapter extends TypeAdapter<Subtopic> {
  @override
  final int typeId = 2;

  @override
  Subtopic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subtopic(
      title: fields[0] as String,
      explanations: (fields[1] as List?)?.cast<String>() ?? <String>[],
      notes: (fields[2] as List?)?.cast<String>() ?? <String>[],
      questions: _coerceQuestions(fields[3]),
      flashcards: (fields[4] as List?)?.cast<Flashcard>() ?? <Flashcard>[],
      subtopics: (fields[5] as List?)?.cast<Subtopic>() ?? <Subtopic>[],
    );
  }

  @override
  void write(BinaryWriter writer, Subtopic obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.explanations)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.questions)
      ..writeByte(4)
      ..write(obj.flashcards)
      ..writeByte(5)
      ..write(obj.subtopics);
  }

  List<Question> _coerceQuestions(dynamic raw) {
    if (raw == null) return <Question>[];
    if (raw is List<Question>) return raw;
    if (raw is List) {
      try {
        return raw.map<Question>((e) {
          if (e is Question) return e;
          if (e is String) return Question(type: 'mcq', prompt: e);
          if (e is Map) return Question.fromJson(Map<String, dynamic>.from(e));
          return Question(type: 'mcq', prompt: e?.toString() ?? '');
        }).toList();
      } catch (_) {
        return <Question>[];
      }
    }
    return <Question>[];
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubtopicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FlashcardAdapter extends TypeAdapter<Flashcard> {
  @override
  final int typeId = 1;

  @override
  Flashcard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Flashcard(
      front: fields[0] as String,
      back: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Flashcard obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.front)
      ..writeByte(1)
      ..write(obj.back);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashcardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
