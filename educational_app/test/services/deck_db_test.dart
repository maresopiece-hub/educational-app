import 'package:flutter_test/flutter_test.dart';
import 'package:educational_app/services/deck_db.dart';
import 'package:educational_app/models/deck.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:educational_app/services/flashcard_db.dart';
import 'package:educational_app/models/flashcard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // use ffi database for tests
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // ensure flashcards table exists (create if missing)
    final db = await FlashcardDb.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS flashcards(
        id TEXT PRIMARY KEY,
        front TEXT,
        back TEXT,
        deck_id TEXT,
        ease REAL,
        interval INTEGER,
        repetitions INTEGER,
        due INTEGER
      )
    ''');
  });

  test('create, list, export and delete deck', () async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final deck = Deck(id: id, name: 'Test Deck');

    await DeckDb.createDeck(deck);
    final list = await DeckDb.listDecks();
    expect(list.any((d) => d.id == id && d.name == 'Test Deck'), true);

  // add a flashcard to the deck and verify export contains it
  final card = Flashcard(id: 'c1-$id', front: 'Q1', back: 'A1', deckId: id);
  await FlashcardDb.saveCard(card);
  final json = await DeckDb.exportDeckJson(id);
  expect(json.contains('Test Deck'), true);
  expect(json.contains(id), true);
  expect(json.contains('Q1'), true);
  expect(json.contains('A1'), true);

    await DeckDb.deleteDeck(id);
    final after = await DeckDb.listDecks();
    expect(after.any((d) => d.id == id), false);
  });
}
