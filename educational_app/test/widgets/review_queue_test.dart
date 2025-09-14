import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:educational_app/widgets/review_queue.dart';
import 'package:educational_app/models/flashcard.dart';

void main() {
  testWidgets('ReviewQueue reveal flow shows answer after tap and calls onReviewed', (tester) async {
    final card = Flashcard(id: '1', front: 'Q', back: 'A', ease: 2.5, interval: 1, repetitions: 0, due: DateTime.now());
    Flashcard? reviewedCard;
    int? reviewedQuality;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ReviewQueue(cards: [card], onReviewed: (c, q) { reviewedCard = c; reviewedQuality = q; }),
      ),
    ));

    // Initially the answer should be hidden and 'Show answer' button present
    expect(find.text('Show answer'), findsOneWidget);
    expect(find.textContaining('Answer:'), findsNothing);

    // Tap show
    await tester.tap(find.text('Show answer'));
    await tester.pumpAndSettle();

    // Answer visible and rating buttons present
    expect(find.textContaining('Answer:'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);

    // Tap Good
    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();

    expect(reviewedCard, isNotNull);
    expect(reviewedCard!.id, '1');
    expect(reviewedQuality, 4);
  });
}
