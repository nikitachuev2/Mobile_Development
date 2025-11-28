import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  DBHelper._internal();
  static final DBHelper instance = DBHelper._internal();

  Database? _db;

  Future<void> initDb() async {
    if (_db != null) return;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'auth_app.db');

    _db = await openDatabase(
      path,
      version: 2, // повысили версию, чтобы добавить таблицу помещений
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Таблица пользователей
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
      );
    ''');

    // Таблица помещений
    await db.execute('''
      CREATE TABLE rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        width REAL NOT NULL,
        depth REAL NOT NULL,
        created_at TEXT NOT NULL
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Если старая версия была 1, а новая 2 — добавляем таблицу помещений
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE rooms (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          width REAL NOT NULL,
          depth REAL NOT NULL,
          created_at TEXT NOT NULL
        );
      ''');
    }
  }

  Database get database {
    if (_db == null) {
      throw Exception(
        'База данных ещё не инициализирована. '
        'Перед использованием вызови DBHelper.instance.initDb();',
      );
    }
    return _db!;
  }
}
