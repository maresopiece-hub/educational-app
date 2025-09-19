import 'package:flutter/material.dart';
import '../models/study_plan.dart';

class StudyModeScreen extends StatefulWidget {
  final StudyPlan plan;
  final List<Subtopic> startPath; // optional starting subtopic path
  const StudyModeScreen({super.key, required this.plan, this.startPath = const []});

  @override
  State<StudyModeScreen> createState() => _StudyModeScreenState();
}

class _StudyModeScreenState extends State<StudyModeScreen> {
  late final List<_StudyItem> _items;
  int _index = 0;
  String? _selectedChoice;
  bool _submitted = false;
  bool _lastAnswerCorrect = false;
  final TextEditingController _freeTextController = TextEditingController();
  // collapse toggles
  bool _showExplanations = true;
  bool _showNotes = true;
  bool _showFlashcards = true;
  bool _showQuestions = true;

  @override
  void initState() {
    super.initState();
    _items = _flatten(widget.plan, widget.startPath);
  }

  List<_StudyItem> _flatten(StudyPlan plan, List<Subtopic> startPath) {
    final out = <_StudyItem>[];

    // Collect items grouped by kind across plan + nested subtopics
    final explanations = <_StudyItem>[];
    final notes = <_StudyItem>[];
    final flashcards = <_StudyItem>[];
    final questions = <_StudyItem>[];

    void visitSubtopic(Subtopic s, List<String> path) {
      final currentPath = [...path, s.title];
      for (var i = 0; i < s.explanations.length; i++) explanations.add(_StudyItem(kind: _StudyKind.explanation, path: currentPath, index: i, text: s.explanations[i]));
      for (var i = 0; i < s.notes.length; i++) notes.add(_StudyItem(kind: _StudyKind.note, path: currentPath, index: i, text: s.notes[i]));
      for (var i = 0; i < s.flashcards.length; i++) flashcards.add(_StudyItem(kind: _StudyKind.flashcard, path: currentPath, index: i, card: s.flashcards[i]));
  for (var i = 0; i < s.questions.length; i++) questions.add(_StudyItem(kind: _StudyKind.question, path: currentPath, index: i, question: s.questions[i]));
      for (final child in s.subtopics) visitSubtopic(child, currentPath);
    }

    final rootPath = [plan.topic];
    for (var i = 0; i < plan.explanations.length; i++) explanations.add(_StudyItem(kind: _StudyKind.explanation, path: rootPath, index: i, text: plan.explanations[i]));
    for (var i = 0; i < plan.notes.length; i++) notes.add(_StudyItem(kind: _StudyKind.note, path: rootPath, index: i, text: plan.notes[i]));
    for (var i = 0; i < plan.flashcards.length; i++) flashcards.add(_StudyItem(kind: _StudyKind.flashcard, path: rootPath, index: i, card: plan.flashcards[i]));
  for (var i = 0; i < plan.questions.length; i++) questions.add(_StudyItem(kind: _StudyKind.question, path: rootPath, index: i, question: plan.questions[i]));

    for (final st in plan.subtopics) visitSubtopic(st, rootPath);

    // Order: all explanations, then notes, then flashcards, then questions
    out.addAll(explanations);
    out.addAll(notes);
    out.addAll(flashcards);
    out.addAll(questions);

    // Respect startPath if provided
    if (startPath.isNotEmpty) {
      final startTitles = startPath.map((s) => s.title).toList();
      final idx = out.indexWhere((it) => _listEquals(it.path, startTitles));
      if (idx >= 0) _index = idx;
    }

    return out;
  }

  bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) if (a[i] != b[i]) return false;
    return true;
  }

  void _markDone(_StudyItem it) async {
    final id = it.id;
    widget.plan.completedItems[id] = DateTime.now().millisecondsSinceEpoch;
    try { await widget.plan.save(); } catch (_) {}
    setState(() {});
  }

  double _computeProgress() {
    if (_items.isEmpty) return 0.0;
    // compute progress by kind with equal weighting: explanations 25%, notes 25%, flashcards 25%, questions 25%
    final byKind = <_StudyKind, List<_StudyItem>>{};
    for (final it in _items) {
      byKind.putIfAbsent(it.kind, () => []).add(it);
    }
    double score = 0.0;
    const kinds = [_StudyKind.explanation, _StudyKind.note, _StudyKind.flashcard, _StudyKind.question];
    for (final k in kinds) {
      final list = byKind[k] ?? [];
      if (list.isEmpty) continue; // empty kind contributes 0 to weighted average (we'll still divide equally across kinds present)
      final done = list.where((it) => widget.plan.completedItems.containsKey(it.id)).length;
      score += (done / list.length) * 0.25; // each kind contributes up to 25%
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return Scaffold(appBar: AppBar(title: const Text('Study Mode')), body: const Center(child: Text('No items to study')));
    final item = _items[_index];
    final progress = _computeProgress();
    return Scaffold(
      appBar: AppBar(title: Text('Study — ${widget.plan.topic}'), actions: [Padding(padding: const EdgeInsets.all(8.0), child: Center(child: Text('${(progress * 100).toStringAsFixed(0)}%')))]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // collapse/expand toggles
          Row(children: [
            TextButton.icon(onPressed: () => setState(() => _showExplanations = !_showExplanations), icon: Icon(_showExplanations ? Icons.expand_less : Icons.expand_more), label: const Text('Explanations')),
            const SizedBox(width: 8),
            TextButton.icon(onPressed: () => setState(() => _showNotes = !_showNotes), icon: Icon(_showNotes ? Icons.expand_less : Icons.expand_more), label: const Text('Notes')),
            const SizedBox(width: 8),
            TextButton.icon(onPressed: () => setState(() => _showFlashcards = !_showFlashcards), icon: Icon(_showFlashcards ? Icons.expand_less : Icons.expand_more), label: const Text('Flashcards')),
            const SizedBox(width: 8),
            TextButton.icon(onPressed: () => setState(() => _showQuestions = !_showQuestions), icon: Icon(_showQuestions ? Icons.expand_less : Icons.expand_more), label: const Text('Questions')),
          ]),

          // respect collapse toggles: if the current item's kind is collapsed, show a helper
          if ((item.kind == _StudyKind.explanation && !_showExplanations) || (item.kind == _StudyKind.note && !_showNotes) || (item.kind == _StudyKind.flashcard && !_showFlashcards) || (item.kind == _StudyKind.question && !_showQuestions))
            Center(child: Column(children: [const Text('This section is collapsed'), ElevatedButton(onPressed: () => setState(() { if (item.kind == _StudyKind.explanation) _showExplanations = true; if (item.kind == _StudyKind.note) _showNotes = true; if (item.kind == _StudyKind.flashcard) _showFlashcards = true; if (item.kind == _StudyKind.question) _showQuestions = true; }), child: const Text('Open'))])),

          Text(item.path.join(' > '), style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Expanded(child: _buildItemView(item)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ElevatedButton(onPressed: _index > 0 ? () { setState(() { _index--; _resetQuestionState(); }); } : null, child: const Text('Back')),
            ElevatedButton(onPressed: () { _markDone(item); if (_index < _items.length - 1) setState(() { _index++; _resetQuestionState(); }); }, child: const Text('Next')),
          ])
        ]),
      ),
    );
  }

  void _resetQuestionState() {
    _selectedChoice = null;
    _submitted = false;
    _lastAnswerCorrect = false;
    _freeTextController.clear();
  }

  Widget _buildItemView(_StudyItem item) {
    switch (item.kind) {
      case _StudyKind.explanation:
      case _StudyKind.note:
        return SingleChildScrollView(child: Text(item.text ?? ''));
      case _StudyKind.flashcard:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.card!.front, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Text(item.card!.back)]);
      case _StudyKind.question:
        final q = item.question!;
        // MCQ / True-False
        if (q.type == 'mcq' || q.type == 'tf') {
          final choices = q.choices.isNotEmpty ? q.choices : (q.type == 'tf' ? ['True', 'False'] : []);
          return SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(q.prompt),
              const SizedBox(height: 12),
              ...choices.map((c) => RadioListTile<String>(value: c, groupValue: _selectedChoice, title: Text(c), onChanged: _submitted ? null : (v) => setState(() => _selectedChoice = v))).toList(),
              const SizedBox(height: 8),
              if (!_submitted)
                ElevatedButton(onPressed: _selectedChoice == null ? null : () => _handleSubmitQuestion(item, q), child: const Text('Submit'))
              else ...[
                if (_lastAnswerCorrect) Row(children: [const Icon(Icons.check_circle, color: Colors.green), const SizedBox(width: 8), const Text('Correct', style: TextStyle(color: Colors.green))]),
                if (!_lastAnswerCorrect) Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.cancel, color: Colors.red), const SizedBox(width: 8), const Text('Incorrect', style: TextStyle(color: Colors.red))]), const SizedBox(height: 8), Text('Answer: ${q.answer}'), if (q.explanation.isNotEmpty) Padding(padding: const EdgeInsets.only(top:8.0), child: Text('Explanation: ${q.explanation}'))])
              ]
            ]),
          );
        }

        // Fill / Essay (free text) — show input and on submit reveal answer/explanation
        return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(q.prompt), const SizedBox(height: 12), TextField(controller: _freeTextController, maxLines: 4, decoration: const InputDecoration(labelText: 'Your answer')), const SizedBox(height: 8), if (!_submitted) ElevatedButton(onPressed: () => _handleSubmitQuestion(item, q), child: const Text('Submit')) else Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Suggested answer: ${q.answer}'), if (q.explanation.isNotEmpty) Padding(padding: const EdgeInsets.only(top:8.0), child: Text('Explanation: ${q.explanation}'))]) ]));
    }
  }

  void _handleSubmitQuestion(_StudyItem item, Question q) {
    setState(() {
      _submitted = true;
      if (q.type == 'mcq' || q.type == 'tf') {
        _lastAnswerCorrect = (_selectedChoice != null && _selectedChoice == q.answer);
        // record attempt
        final id = item.id;
        widget.plan.questionAttempts[id] = (widget.plan.questionAttempts[id] ?? 0) + 1;
        if (_lastAnswerCorrect) {
          widget.plan.questionCorrect[id] = (widget.plan.questionCorrect[id] ?? 0) + 1;
        }
        try { widget.plan.save(); } catch (_) {}
        if (_lastAnswerCorrect) {
          // mark done and auto-advance
          _markDone(item);
          Future.delayed(const Duration(milliseconds: 700), () {
            if (!mounted) return;
            if (_index < _items.length - 1) setState(() { _index++; _resetQuestionState(); });
          });
        }
      } else {
        // free-text/essay: reveal suggested answer but do not auto advance
        // don't mark done automatically; user can press Next to mark
      }
    });
  }
}

enum _StudyKind { explanation, note, flashcard, question }

class _StudyItem {
  final _StudyKind kind;
  final List<String> path;
  final int index;
  final String? text;
  final Flashcard? card;
  final Question? question;
  _StudyItem({required this.kind, required this.path, required this.index, this.text, this.card, this.question});

  String get id => '${kind.toString().split('.').last}:${path.join('|')}:$index';
}
