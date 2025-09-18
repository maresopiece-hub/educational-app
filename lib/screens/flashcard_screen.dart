import 'package:flutter/material.dart';
import '../models/lesson_plan_model.dart';

class FlashcardScreen extends StatefulWidget {
  final LessonPlan? lessonPlan;
  const FlashcardScreen({super.key, this.lessonPlan});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late List<Map<String, String>> _cards;
  int _current = 0;
  bool _showBack = false;
  late List<bool?> _progress; // null: not answered, true: known, false: unknown
  bool _fastRevision = false;

  @override
  void initState() {
  super.initState();
  _cards = _generateCardsFromPlan(widget.lessonPlan);
  _progress = List<bool?>.filled(_cards.length, null);
  }

  List<Map<String, String>> _generateCardsFromPlan(LessonPlan? plan) {
    if (plan == null) {
      return [
        {'front': 'What is photosynthesis?', 'back': 'Process by which plants make food using sunlight.'},
        {'front': 'E = mc^2', 'back': 'Einstein’s mass-energy equivalence.'},
      ];
    }
    final cards = <Map<String, String>>[];
    for (final section in plan.sections) {
      for (final q in section.questions) {
        cards.add({
          'front': q['question'] ?? '',
          'back': 'Answer: ${q['answer'] ?? ''}',
        });
      }
    }
    if (cards.isEmpty) {
      cards.add({'front': 'No questions found in plan.', 'back': ''});
    }
    return cards;
  }

  void _nextCard() {
    setState(() {
      _showBack = false;
      _current = (_current + 1) % _cards.length;
    });
  }

  void _markCard(bool known) {
    setState(() {
      _progress[_current] = known;
    });
    _nextCard();
  }

  void _flipCard() {
    setState(() {
      _showBack = !_showBack;
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = _cards[_current];
    int knownCount = _progress.where((v) => v == true).length;
    int unknownCount = _progress.where((v) => v == false).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: [
          IconButton(
            icon: Icon(_fastRevision ? Icons.flip_to_front : Icons.view_list),
            tooltip: _fastRevision ? 'Normal Mode' : 'Fast Revision',
            onPressed: () {
              setState(() {
                _fastRevision = !_fastRevision;
              });
            },
          ),
        ],
      ),
      body: _fastRevision
          ? ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _cards.length,
              separatorBuilder: (_, __) => const Divider(height: 32),
              itemBuilder: (context, i) {
                return Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Q${i + 1}: ${_cards[i]['front']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Text(_cards[i]['back'] ?? '', style: const TextStyle(fontSize: 16)),
                        if (_progress[i] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(_progress[i]! ? 'Known' : 'Unknown', style: TextStyle(color: _progress[i]! ? Colors.green : Colors.red)),
                          ),
                      ],
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8),
                    child: LinearProgressIndicator(
                      value: (_progress.where((v) => v != null).length) / _cards.length,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blueAccent,
                    ),
                  ),
                  Text('Progress: ${_progress.where((v) => v != null).length} / ${_cards.length}'),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _flipCard,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 300,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _showBack ? card['back']! : card['front']!,
                        style: const TextStyle(color: Colors.white, fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Card ${_current + 1} of ${_cards.length}'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _markCard(true),
                        icon: const Icon(Icons.check, color: Colors.green),
                        label: const Text('Known'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[100]),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _markCard(false),
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text('Unknown'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Known: $knownCount   Unknown: $unknownCount'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _nextCard,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
    );
  }
}
