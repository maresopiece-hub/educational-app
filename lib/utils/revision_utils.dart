import '../models/study_plan.dart';

class RevisionStats {
  final String planTopic;
  final List<String> path; // empty list indicates root topic
  final int attempts;
  final int correct;

  RevisionStats({required this.planTopic, required this.path, required this.attempts, required this.correct});

  double get percentCorrect => attempts == 0 ? 0.0 : correct / attempts;
}

/// Walk a StudyPlan and collect per-question attempt/correct stats grouped by path (topic -> subtopic path)
List<RevisionStats> collectRevisionStats(StudyPlan plan) {
  final Map<String, RevisionStats> map = {};

  void addForQuestion(String pathKey, List<String> path, int attempts, int correct) {
    final existing = map[pathKey];
    if (existing == null) {
      map[pathKey] = RevisionStats(planTopic: plan.topic, path: path, attempts: attempts, correct: correct);
    } else {
      map[pathKey] = RevisionStats(planTopic: plan.topic, path: path, attempts: existing.attempts + attempts, correct: existing.correct + correct);
    }
  }

  // process root-level questions
  for (var i = 0; i < plan.questions.length; i++) {
    final id = 'question:${[plan.topic].join('|')}:$i';
    final attempts = plan.questionAttempts[id] ?? 0;
    final correct = plan.questionCorrect[id] ?? 0;
    addForQuestion(plan.topic, [plan.topic], attempts, correct);
  }

  // recursive traversal for subtopics
  void visit(Subtopic s, List<String> path) {
    final currentPath = [...path, s.title];
    for (var i = 0; i < s.questions.length; i++) {
      final id = 'question:${currentPath.join('|')}:$i';
      final attempts = plan.questionAttempts[id] ?? 0;
      final correct = plan.questionCorrect[id] ?? 0;
      addForQuestion(plan.topic, currentPath, attempts, correct);
    }
    for (final child in s.subtopics) visit(child, currentPath);
  }

  for (final st in plan.subtopics) visit(st, [plan.topic]);

  return map.values.toList();
}

/// Aggregate stats across multiple plans and return sorted weakest-first (lowest percentCorrect with attempts prioritized)
List<RevisionStats> rankWeakest(List<StudyPlan> plans, {bool favoritesOnly = false}) {
  final Map<String, RevisionStats> agg = {};
  for (final plan in plans) {
    if (favoritesOnly && !plan.favorite) continue;
    final stats = collectRevisionStats(plan);
    for (final s in stats) {
      final key = '${s.planTopic}:${s.path.join('|')}';
      final ex = agg[key];
      if (ex == null) {
        agg[key] = RevisionStats(planTopic: s.planTopic, path: s.path, attempts: s.attempts, correct: s.correct);
      } else {
        agg[key] = RevisionStats(planTopic: ex.planTopic, path: ex.path, attempts: ex.attempts + s.attempts, correct: ex.correct + s.correct);
      }
    }
  }

  final list = agg.values.toList();
  list.sort((a, b) {
    // sort by percentCorrect ascending, tiebreaker: more attempts first
    final pa = a.percentCorrect;
    final pb = b.percentCorrect;
    if (pa == pb) return b.attempts.compareTo(a.attempts);
    return pa.compareTo(pb);
  });
  return list;
}
