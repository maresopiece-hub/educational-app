import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._init();
  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tutor.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT,
        name TEXT,
        plans TEXT,
        progress TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE flashcards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT,
        front TEXT,
        back TEXT,
        topic TEXT,
        completed INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE study_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT,
        pdfName TEXT,
        plan TEXT,
        progress INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE activity_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT,
        type TEXT,
        timestamp INTEGER
      )
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUser(String id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  // Local user authentication (simple, not secure for production)
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND progress = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> registerUser(String email, String password) async {
    final db = await database;
    // For demo, store password in 'progress' field (not secure, just for local demo)
    final user = {
      'id': email,
      'email': email,
      'name': email.split('@')[0],
      'plans': '',
      'progress': password,
    };
    await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
    return user;
  }
  Future<List<Map<String, dynamic>>> getFlashcards(String userId) async {
    final db = await database;
    return await db.query('flashcards', where: 'userId = ?', whereArgs: [userId]);
  }

  /// Initialize an in-memory database (useful for tests)
  Future<void> initInMemory() async {
    // Close previous in-memory DB if present to ensure a fresh instance
    if (_database != null) {
      try {
        await _database!.close();
      } catch (_) {}
      _database = null;
    }
    _database = await openDatabase(':memory:', version: 1, onCreate: _createDB);
  }

  /// Log an activity for a user (type can be 'study', 'flashcard', etc.)
  Future<void> logActivity(String userId, String type, {DateTime? at}) async {
    final db = await database;
    final ts = (at ?? DateTime.now()).millisecondsSinceEpoch;
    await db.insert('activity_logs', {'userId': userId, 'type': type, 'timestamp': ts});
  }

  /// Returns number of consecutive days (including today) with activity for [userId].
  Future<int> getConsecutiveActiveDays(String userId) async {
    final db = await database;
    final rows = await db.query('activity_logs', columns: ['timestamp'], where: 'userId = ?', whereArgs: [userId]);
    final dateSet = <DateTime>{};
    for (final r in rows) {
      final ts = r['timestamp'] as int?;
      if (ts == null) continue;
      final dt = DateTime.fromMillisecondsSinceEpoch(ts);
      dateSet.add(DateTime(dt.year, dt.month, dt.day));
    }

    var streak = 0;
    var current = DateTime.now();
    while (true) {
      final d = DateTime(current.year, current.month, current.day);
      if (dateSet.contains(d)) {
        streak += 1;
        current = current.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // Insert flashcard, update progress, etc.
}
