import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/flashcard.dart';

class FlashcardDb {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = await getDatabasesPath();
    final dbPath = p.join(path, 'flashcards.db');
    _db = await openDatabase(dbPath, version: 2, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE flashcards(
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
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        // add nullable deck_id column for deck association
        await db.execute('ALTER TABLE flashcards ADD COLUMN deck_id TEXT');
      }
    });
    return _db!;
  }

  static Future<void> saveCard(Flashcard c) async {
    final db = await database;
    await db.insert('flashcards', {
      'id': c.id,
      'front': c.front,
      'back': c.back,
      'deck_id': c.deckId,
      'ease': c.ease,
      'interval': c.interval,
      'repetitions': c.repetitions,
      'due': c.due.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Flashcard>> loadDue(DateTime at) async {
    final db = await database;
    final rows = await db.query('flashcards', where: 'due <= ?', whereArgs: [at.millisecondsSinceEpoch]);
    return rows.map((r) => Flashcard(
          id: r['id'] as String,
          front: r['front'] as String,
          back: r['back'] as String,
          deckId: r['deck_id'] as String?,
          ease: (r['ease'] as num).toDouble(),
          interval: r['interval'] as int,
          repetitions: r['repetitions'] as int,
          due: DateTime.fromMillisecondsSinceEpoch(r['due'] as int),
        )).toList();
  }
}
