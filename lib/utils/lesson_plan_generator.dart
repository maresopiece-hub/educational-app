// dart:math not needed currently

import '../models/study_plan.dart';

class LessonPlanGenerator {
  static Future<List<StudyPlan>> generateFromText(String rawText) async {
    final plans = <StudyPlan>[];
    if (rawText.trim().isEmpty) return plans;

    // Split into candidate sections by headings or double newlines
    final candidates = _splitIntoSections(rawText);

    for (final sec in candidates.take(10)) {
      final topic = _extractTopic(sec);
  final subtopicStrings = _extractSubtopics(sec);
  final subtopics = subtopicStrings.map((s) => Subtopic(title: s)).toList();
      final explanations = _extractExplanations(sec);
      final notes = _extractNotes(sec);
      final questions = _generateQuestions(sec);
  final flashcards = _generateFlashcards(subtopics, explanations);

      plans.add(StudyPlan(
        topic: topic,
        subtopics: subtopics,
        explanations: explanations,
        notes: notes,
        questions: questions,
        flashcards: flashcards,
      ));
    }

    return plans;
  }

  static List<String> _splitIntoSections(String text) {
    // Try to split on headings like '1. Topic' or blank-line separated paragraphs
    final lines = text.split(RegExp(r'\r?\n'));
    final sections = <String>[];
    final buffer = StringBuffer();
    final headingRe = RegExp(r'^(\d+\.|Chapter|CHAPTER|[A-Z][A-Za-z ]{3,})');
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) {
        buffer.writeln();
        continue;
      }
      if (headingRe.hasMatch(line) && buffer.isNotEmpty) {
        sections.add(buffer.toString().trim());
        buffer.clear();
      }
      buffer.writeln(line);
    }
    if (buffer.isNotEmpty) sections.add(buffer.toString().trim());
    return sections.where((s) => s.trim().isNotEmpty).toList();
  }

  static String _extractTopic(String section) {
    // First non-empty line as topic, strip leading numeration
    final firstLine = section.split(RegExp(r'\r?\n')).first.trim();
    final cleaned = firstLine.replaceFirst(RegExp(r'^\d+\.\s*'), '');
    return cleaned.isEmpty ? 'Untitled' : cleaned;
  }

  static List<String> _extractSubtopics(String section) {
    final lines = section.split(RegExp(r'\r?\n'));
    final subs = <String>[];
    for (final l in lines) {
      final t = l.trim();
      if (t.startsWith('-') || t.startsWith('*') || RegExp(r'^\d+\.').hasMatch(t)) {
        subs.add(t.replaceFirst(RegExp(r'^[-*\d\.\s]+'), '').trim());
      }
    }
    return subs;
  }

  static List<String> _extractExplanations(String section) {
    // Paragraphs that are not bullets
    final paragraphs = section.split(RegExp(r'\r?\n\r?\n'));
    final expl = <String>[];
    for (final p in paragraphs) {
      final clean = p.replaceAll(RegExp(r'^[-*\d\.\s]+', multiLine: true), '').trim();
      if (clean.isNotEmpty && clean.split(RegExp(r'\s+')).length > 6) {
        expl.add(clean);
      }
    }
    return expl;
  }

  static List<String> _extractNotes(String section) {
    final lines = section.split(RegExp(r'\r?\n'));
    final notes = <String>[];
    for (final l in lines) {
      final t = l.trim();
      if ((t.startsWith('-') || t.startsWith('*') || t.length < 80) && !RegExp(r'^\d+\.').hasMatch(t)) {
        final one = t.replaceFirst(RegExp(r'^[-*\d\.\s]+'), '').trim();
        if (one.isNotEmpty && one.split(RegExp(r'\s+')).length <= 20) notes.add(one);
      }
    }
    return notes;
  }

  static List<String> _generateQuestions(String section) {
    final sentences = <String>[];
    final rawSentences = section.split(RegExp(r'(?<=[.?!])\s+'));
    for (final s in rawSentences) {
      final clean = s.trim();
      if (clean.length > 20) sentences.add(clean);
    }
    final questions = <String>[];
    for (final s in sentences.take(5)) {
      // naive transforms: 'X is Y.' -> 'What is X?'
  final m = RegExp(r'^(.*?)\s+is\s+(.*?)[.?!]?\u0000*', dotAll: true).firstMatch('$s\u0000');
      if (m != null) {
        final subject = m.group(1)!.trim();
  questions.add('What is $subject?');
      } else {
        // fallback: convert final '.' to '?'
        questions.add(s.replaceAll(RegExp(r'[.?!]$'), '?'));
      }
    }
    return questions;
  }

  static List<Flashcard> _generateFlashcards(List<Subtopic> subs, List<String> expl) {
    final cards = <Flashcard>[];
    for (var i = 0; i < subs.length && cards.length < 8; i++) {
      final front = subs[i].title;
      final back = i < expl.length ? (expl[i].length > 200 ? '${expl[i].substring(0, 200)}...' : expl[i]) : 'See notes';
      cards.add(Flashcard(front: front, back: back));
    }
    // If no subs, try generate from expl snippets
    if (cards.isEmpty && expl.isNotEmpty) {
      for (var i = 0; i < expl.length && i < 4; i++) {
        final front = expl[i].split(RegExp(r'\.|,')).first;
        final back = expl[i];
        cards.add(Flashcard(front: front, back: back));
      }
    }
    return cards;
  }
}
