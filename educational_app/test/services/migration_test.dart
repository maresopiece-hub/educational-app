import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:educational_app/services/flashcard_db.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('migrates flashcards table to include deck_id', () async {
    final path = await getDatabasesPath();
    final dbPath = p.join(path, 'flashcards.db');

    // remove any existing test DB file
    try {
      final f = File(dbPath);
      if (await f.exists()) await f.delete();
    } catch (_) {}

    // create version 1 DB with flashcards table (no deck_id)
    final db1 = await openDatabase(dbPath, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE flashcards(
          id TEXT PRIMARY KEY,
          front TEXT,
          back TEXT,
          ease REAL,
          interval INTEGER,
          repetitions INTEGER,
          due INTEGER
        )
      ''');
    });
    await db1.close();

    // Now open via our FlashcardDb (which uses version 2 and onUpgrade to add deck_id)
    final db = await FlashcardDb.database;

    // check pragma table_info to confirm deck_id exists
    final info = await db.rawQuery("PRAGMA table_info('flashcards')");
    final columns = info.map((r) => r['name'] as String).toList();
    expect(columns.contains('deck_id'), true);
  });
}
