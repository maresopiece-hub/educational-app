import 'package:flutter/material.dart';
import '../services/flashcard_db.dart';
import '../models/flashcard.dart';
import '../widgets/review_queue.dart';
import '../services/srs_service.dart';

class StudyTodayScreen extends StatefulWidget {
  const StudyTodayScreen({super.key});

  @override
  State<StudyTodayScreen> createState() => _StudyTodayScreenState();
}

class _StudyTodayScreenState extends State<StudyTodayScreen> {
  List<Flashcard> _cards = [];
  bool _loading = true;
  final _srs = SrsService();

  @override
  void initState() {
    super.initState();
    _loadDue();
  }

  Future<void> _loadDue() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    final cards = await FlashcardDb.loadDue(now);
    setState(() {
      _cards = cards;
      _loading = false;
    });
  }

  void _onReviewed(Flashcard card, int quality) {
    setState(() {
      _srs.updateCard(card, quality);
    });
    FlashcardDb.saveCard(card);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Today')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
              ? const Center(child: Text('No cards due today.'))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ReviewQueue(cards: _cards, onReviewed: _onReviewed),
                ),
    );
  }
}
