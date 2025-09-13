import 'package:flutter/material.dart';

class ExamModeScreen extends StatefulWidget {
  const ExamModeScreen({Key? key}) : super(key: key);

  @override
  State<ExamModeScreen> createState() => _ExamModeScreenState();
}

class _ExamModeScreenState extends State<ExamModeScreen> {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the capital of France?',
      'options': ['Paris', 'London', 'Berlin', 'Rome'],
      'answer': 'Paris',
      'whyWrong': {
        'London': 'London is the capital of the UK.',
        'Berlin': 'Berlin is the capital of Germany.',
        'Rome': 'Rome is the capital of Italy.'
      }
    },
    // Add more questions or load dynamically
  ];
  int _current = 0;
  String? _selected;
  bool _showResult = false;
  int _score = 0;
  bool _finished = false;

  void _submit() {
    if (_selected == null) return;
    setState(() {
      _showResult = true;
      if (_selected == _questions[_current]['answer']) {
        _score++;
      }
    });
  }

  void _next() {
    setState(() {
      if (_current < _questions.length - 1) {
        _current++;
        _selected = null;
        _showResult = false;
      } else {
        _finished = true;
      }
    });
  }

  void _restart() {
    setState(() {
      _current = 0;
      _selected = null;
      _showResult = false;
      _score = 0;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Mode')),
      body: _finished
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Exam Complete!', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Text('Score: $_score / ${_questions.length}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _restart,
                    child: const Text('Restart'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Question ${_current + 1} of ${_questions.length}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Text(_questions[_current]['question'], style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  ...(_questions[_current]['options'] as List<String>).map((opt) => RadioListTile<String>(
                        value: opt,
                        groupValue: _selected,
                        onChanged: _showResult ? null : (val) => setState(() => _selected = val),
                        title: Text(opt),
                      )),
                  if (_showResult)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _selected == _questions[_current]['answer']
                            ? 'Correct!'
                            : 'Incorrect: ${_questions[_current]['whyWrong'][_selected] ?? 'No explanation.'}',
                        style: TextStyle(
                          color: _selected == _questions[_current]['answer'] ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!_showResult)
                        ElevatedButton(
                          onPressed: _selected != null ? _submit : null,
                          child: const Text('Submit'),
                        ),
                      if (_showResult)
                        ElevatedButton(
                          onPressed: _next,
                          child: Text(_current < _questions.length - 1 ? 'Next' : 'Finish'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
