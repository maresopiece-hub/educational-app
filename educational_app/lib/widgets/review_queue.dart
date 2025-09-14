import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class ReviewQueue extends StatefulWidget {
  final List<Flashcard> cards;
  final void Function(Flashcard, int) onReviewed; // quality 0-5
  const ReviewQueue({super.key, required this.cards, required this.onReviewed});

  @override
  State<ReviewQueue> createState() => _ReviewQueueState();
}

class _ReviewQueueState extends State<ReviewQueue> {
  int _index = 0;
  bool _revealed = false;

  void _record(int quality) {
    final card = widget.cards[_index];
    widget.onReviewed(card, quality);
    setState(() {
      _revealed = false;
      if (_index < widget.cards.length - 1) _index++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) return const Center(child: Text('No cards'));
    final card = widget.cards[_index];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Card ${_index + 1}/${widget.cards.length}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(card.front, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            // Reveal flow: hide answer until user taps Show
            if (!_revealed) ...[
              ElevatedButton(
                onPressed: () => setState(() => _revealed = true),
                child: const Text('Show answer'),
              ),
            ] else ...[
              Text('Answer: ${card.back}', style: const TextStyle(fontStyle: FontStyle.italic)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(onPressed: () => _record(2), child: const Text('Hard')),
                  ElevatedButton(onPressed: () => _record(4), child: const Text('Good')),
                  ElevatedButton(onPressed: () => _record(5), child: const Text('Easy')),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}
