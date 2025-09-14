import '../models/lesson_plan.dart';
import '../models/section_model.dart';

class LessonGeneratorService {

  LessonPlan generateFromSections(List<SectionModel> sections,
      {String? title, int questionsPerSection = 3, int keywordsPerSection = 6, int examplesPerSection = 1}) {
    final planSections = <LessonSection>[];
    for (final s in sections) {
      final keywords = (s.keywords.isNotEmpty ? s.keywords : _extractKeywords(s.text, top: keywordsPerSection)).take(keywordsPerSection).toList();
      final explanation = _generateExplanation(s.text);
      final examples = _generateExamples(s.text, examplesPerSection);
      final questions = _generateQuestions(s.text, keywords, questionsPerSection);
      planSections.add(LessonSection(id: s.id, title: s.title, explanation: explanation, examples: examples, questions: questions, keywords: keywords, completeness: s.completeness));
    }
    return LessonPlan(title: title ?? 'Lesson Plan', sections: planSections);
  }

  String _generateExplanation(String text) {
    // Simple deterministic rule: take first 2 sentences or first 120 words, whichever is shorter, then simplify by trimming.
    final sentences = _splitToSentences(text);
    if (sentences.isNotEmpty) {
      final take = sentences.length >= 2 ? sentences.take(2).join(' ') : sentences.join(' ');
      return _shorten(take, 120);
    }
    return _shorten(text, 120);
  }

  List<String> _generateExamples(String text, int n) {
    final sentences = _splitToSentences(text);
    final out = <String>[];
    for (var i = 0; i < n; i++) {
      if (i < sentences.length) {
        out.add('Worked example: ${_shorten(sentences[i], 140)}');
      } else {
        out.add('Worked example: ${_shorten(text, 140)}');
      }
    }
    return out;
  }

  List<Question> _generateQuestions(String text, List<String> keywords, int perSection) {
    final qs = <Question>[];
    // Ensure at least 1 MCQ, 1 short answer, 1 fill-in if perSection >=3
    final sentences = _splitToSentences(text);
    // MCQ
    if (perSection >= 1) {
      final mcqTarget = keywords.isNotEmpty ? keywords[0] : _pickToken(text) ?? 'answer';
      final options = _makeMcqOptions(mcqTarget, keywords);
      qs.add(Question(type: QuestionType.mcq, prompt: 'Which of the following is correct about ${_shorten(mcqTarget, 30)}?', answer: mcqTarget, options: options, rationale: 'Correct because $mcqTarget is referenced in the section.'));
    }
    // Short answer
    if (perSection >= 2) {
      final sa = sentences.isNotEmpty ? sentences.first : text;
      final answer = keywords.isNotEmpty ? keywords.first : _pickToken(sa) ?? 'answer';
      qs.add(Question(type: QuestionType.shortAnswer, prompt: 'Explain: ${_shorten(sa, 80)}', answer: answer, rationale: 'Key point: $answer.'));
    }
    // Fill-in the blank
    if (perSection >= 3) {
      final sentence = sentences.isNotEmpty ? sentences.length > 1 ? sentences[1] : sentences.first : text;
      final blank = keywords.length > 1 ? keywords[1] : _pickToken(sentence) ?? 'answer';
      final prompt = sentence.replaceFirst(blank, '_____');
      qs.add(Question(type: QuestionType.fillIn, prompt: _shorten(prompt, 120), answer: blank, rationale: 'The blank refers to $blank.'));
    }
    // If more questions requested, generate simple short answer variants
    for (var i = 3; i < perSection; i++) {
      final txt = sentences.isNotEmpty ? sentences[i % sentences.length] : text;
      final answer = _pickToken(txt) ?? 'answer';
      qs.add(Question(type: QuestionType.shortAnswer, prompt: 'Describe: ${_shorten(txt, 80)}', answer: answer, rationale: 'Look for $answer.'));
    }
    return qs;
  }

  List<String> _extractKeywords(String text, {int top = 6}) {
    final words = text.toLowerCase().replaceAll(RegExp(r"[^a-z0-9\s]"), ' ').split(RegExp(r'\s+')).where((w) => w.length > 3).toList();
    final freq = <String, int>{};
    for (final w in words) {
      freq[w] = (freq[w] ?? 0) + 1;
    }
    final sorted = freq.keys.toList()..sort((a, b) => freq[b]!.compareTo(freq[a]!));
    return sorted.take(top).toList();
  }

  List<String> _splitToSentences(String text) {
    final raw = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final pattern = RegExp(r'(?<=[.!?])\s+');
    final tentative = raw.split(pattern);
    return tentative.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  String? _pickToken(String text) {
    final words = text.replaceAll(RegExp(r"[^a-zA-Z0-9 ]"), ' ').split(RegExp(r'\s+')).where((w) => w.length > 3).toList();
    return words.isNotEmpty ? words.first : null;
  }

  String _shorten(String text, int maxWords) {
    final words = text.split(RegExp(r'\s+'));
    if (words.length <= maxWords) return text.trim();
    return words.take(maxWords).join(' ').trim() + '...';
  }

  List<String> _makeMcqOptions(String correct, List<String> keywords) {
    final opts = <String>[correct];
    for (final k in keywords) {
      if (opts.length >= 4) break;
      if (k != correct) opts.add(k);
    }
    // pad with small edits of correct if needed
    var seed = 0;
    while (opts.length < 4) {
      seed++;
      opts.add('$correct$seed');
    }
    opts.shuffle();
    return opts;
  }
}
