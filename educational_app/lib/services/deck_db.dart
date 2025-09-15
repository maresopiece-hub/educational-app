import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/deck.dart';
// ...existing code...

class DeckDb {
  static Database? _db;

  // Reuse flashcards.db path and ensure decks table exists
  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = await getDatabasesPath();
    final dbPath = p.join(path, 'flashcards.db');
    _db = await openDatabase(dbPath, version: 2);
    await _db!.execute('''
      CREATE TABLE IF NOT EXISTS decks(
        id TEXT PRIMARY KEY,
        name TEXT,
        created_at INTEGER
      )
    ''');
    return _db!;
  }

  static Future<void> createDeck(Deck d) async {
    final db = await database;
    await db.insert('decks', {'id': d.id, 'name': d.name, 'created_at': d.createdAt.millisecondsSinceEpoch}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Deck>> listDecks() async {
    final db = await database;
    final rows = await db.query('decks');
    return rows.map((r) => Deck(id: r['id'] as String, name: r['name'] as String, createdAt: DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int))).toList();
  }

  static Future<void> deleteDeck(String id) async {
    final db = await database;
    // remove association from flashcards (set deck_id NULL) then delete deck
    try {
      await db.update('flashcards', {'deck_id': null}, where: 'deck_id = ?', whereArgs: [id]);
    } catch (_) {
      // ignore if flashcards table not present in test DB
    }
    await db.delete('decks', where: 'id = ?', whereArgs: [id]);
  }

  static Future<String> exportDeckJson(String id) async {
    final db = await database;
    final deckRows = await db.query('decks', where: 'id = ?', whereArgs: [id]);
    if (deckRows.isEmpty) throw Exception('deck not found');
    final deck = deckRows.first;
    List<Map<String, Object?>> cards;
    try {
      cards = await db.query('flashcards', where: 'deck_id = ?', whereArgs: [id]);
    } catch (_) {
      // If flashcards table doesn't exist yet, return empty card list
      cards = <Map<String, Object?>>[];
    }
    final out = {
      'deck': {'id': deck['id'], 'name': deck['name'], 'created_at': deck['created_at']},
      'cards': cards
    };
    return jsonEncode(out);
  }
}
