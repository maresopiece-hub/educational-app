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
    return StudyPlan(
      topic: fields[1] as String,
      subject: fields[0] as String?,
      subtopics: (fields[2] as List?)?.cast<Subtopic>(),
      explanations: (fields[3] as List?)?.cast<String>(),
      notes: (fields[4] as List?)?.cast<String>(),
      questions: (fields[5] as List?)?.cast<String>(),
      flashcards: (fields[6] as List?)?.cast<Flashcard>(),
    );
  }

  @override
  void write(BinaryWriter writer, StudyPlan obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.flashcards);
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
      explanations: (fields[1] as List?)?.cast<String>(),
      notes: (fields[2] as List?)?.cast<String>(),
      questions: (fields[3] as List?)?.cast<String>(),
      flashcards: (fields[4] as List?)?.cast<Flashcard>(),
    );
  }

  @override
  void write(BinaryWriter writer, Subtopic obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.explanations)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.questions)
      ..writeByte(4)
      ..write(obj.flashcards);
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
