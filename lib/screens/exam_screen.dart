
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/lesson_plan_model.dart';

class ExamScreen extends StatefulWidget {
  final LessonPlan? lessonPlan;
  const ExamScreen({super.key, this.lessonPlan});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late List<Map<String, dynamic>> _questions;
  int _current = 0;
  String? _selected;
  int _score = 0;
  bool _showResult = false;
  bool _reviewMode = false;
  List<String?> _userAnswers = [];
  late Stopwatch _stopwatch;
  late int _timerSeconds;
  late int _totalTime;
  Timer? _timer;

  @override
  void initState() {
  super.initState();
  _questions = _generateQuestionsFromPlan(widget.lessonPlan);
  _userAnswers = List<String?>.filled(_questions.length, null);
  _timerSeconds = 60 * _questions.length; // 1 min per question
  _totalTime = _timerSeconds;
  _stopwatch = Stopwatch()..start();
  _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  _timer?.cancel();
  super.dispose();
  }

  void _onTick(Timer timer) {
    if (!mounted) return;
    setState(() {
      if (_timerSeconds > 0 && !_showResult) {
        _timerSeconds = _totalTime - _stopwatch.elapsed.inSeconds;
        if (_timerSeconds <= 0) {
          _timerSeconds = 0;
          _showResult = true;
          _stopwatch.stop();
          _timer?.cancel();
        }
      }
    });
  }

  List<Map<String, dynamic>> _generateQuestionsFromPlan(LessonPlan? plan) {
    if (plan == null) {
      return [
        {
          'question': 'What is the capital of France?',
          'options': ['Paris', 'London', 'Berlin', 'Rome'],
          'answer': 'Paris',
        },
        {
          'question': '2 + 2 = ?',
          'options': ['3', '4', '5', '6'],
          'answer': '4',
        },
      ];
    }
    final questions = <Map<String, dynamic>>[];
    for (final section in plan.sections) {
      for (final q in section.questions) {
        questions.add({
          'question': q['question'] ?? '',
          'options': q['options'] ?? [],
          'answer': q['answer'] ?? '',
        });
      }
    }
    if (questions.isEmpty) {
      questions.add({
        'question': 'No questions found in plan.',
        'options': ['A', 'B', 'C', 'D'],
        'answer': 'A',
      });
    }
    return questions;
  }

  void _nextQuestion() {
    _userAnswers[_current] = _selected;
    if (_selected == _questions[_current]['answer']) {
      _score++;
    }
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _selected = null;
      });
    } else {
      setState(() {
        _showResult = true;
        _stopwatch.stop();
      });
    }
  }

  void _restart() {
    setState(() {
      _current = 0;
      _selected = null;
      _score = 0;
      _showResult = false;
      _reviewMode = false;
      _userAnswers = List<String?>.filled(_questions.length, null);
      _timerSeconds = 60 * _questions.length;
      _totalTime = _timerSeconds;
      _stopwatch.reset();
      _stopwatch.start();
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      if (_reviewMode) {
        // Review answers screen
        return Scaffold(
          appBar: AppBar(title: const Text('Review Answers')),
          body: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: _questions.length,
            separatorBuilder: (_, __) => const Divider(height: 32),
            itemBuilder: (context, i) {
              final q = _questions[i];
              final userAns = _userAnswers[i];
              final correct = userAns == q['answer'];
              return Card(
                color: correct ? Colors.green[50] : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Q${i + 1}: ${q['question']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Your answer: ${userAns ?? "No answer"}', style: TextStyle(color: correct ? Colors.green : Colors.red)),
                      Text('Correct answer: ${q['answer']}', style: const TextStyle(color: Colors.blue)),
                    ],
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _restart,
              child: const Text('Restart Exam'),
            ),
          ),
        );
      }
      // Summary screen
      final timeTaken = _totalTime - _timerSeconds;
      return Scaffold(
        appBar: AppBar(title: const Text('Exam Result')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Score: $_score / ${_questions.length}', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 12),
              Text('Time taken: ${_formatTime(timeTaken)}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => setState(() => _reviewMode = true),
                child: const Text('Review Answers'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _restart,
                child: const Text('Restart'),
              ),
            ],
          ),
        ),
      );
    }
    final q = _questions[_current];
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Mode')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question ${_current + 1} of ${_questions.length}', style: const TextStyle(fontSize: 18)),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 20),
                    const SizedBox(width: 4),
                    Text(_formatTime(_timerSeconds), style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(q['question'], style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Column(
              children: [
                for (final opt in q['options'])
                  ListTile(
                    leading: Radio<String>(
                      value: opt,
                      groupValue: _selected,
                      onChanged: (val) => setState(() => _selected = val),
                    ),
                    title: Text(opt),
                    onTap: () => setState(() => _selected = opt),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _selected == null ? null : _nextQuestion,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}' ;
  }
}
