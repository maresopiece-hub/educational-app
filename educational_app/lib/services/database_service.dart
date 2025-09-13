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

  // Insert flashcard, update progress, etc.
}
