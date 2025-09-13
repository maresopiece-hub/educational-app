import 'package:flutter/material.dart';
import '../services/database_service.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Map<String, dynamic>> _flashcards = [];
  int _current = 0;
  bool _showAnswer = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    setState(() => _isLoading = true);
    // For demo, use a static userId. Replace with actual user/session logic.
    final userId = 'demo_user';
    final db = DatabaseService.instance;
    final cards = await db.getFlashcards(userId);
    setState(() {
      _flashcards = cards;
      _isLoading = false;
      _current = 0;
      _showAnswer = false;
    });
  }

  void _nextCard() {
    setState(() {
      _current = (_current + 1) % _flashcards.length;
      _showAnswer = false;
    });
  }

  void _prevCard() {
    setState(() {
      _current = (_current - 1 + _flashcards.length) % _flashcards.length;
      _showAnswer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _flashcards.isEmpty
              ? const Center(child: Text('No flashcards found.'))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: InkWell(
                        onTap: () => setState(() => _showAnswer = !_showAnswer),
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          alignment: Alignment.center,
                          child: Text(
                            _showAnswer
                                ? (_flashcards[_current]['back'] ?? 'No answer')
                                : (_flashcards[_current]['front'] ?? 'No question'),
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _prevCard,
                        ),
                        Text('${_current + 1} / ${_flashcards.length}'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _nextCard,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadFlashcards,
                      child: const Text('Reload'),
                    ),
                  ],
                ),
    );
  }
}
