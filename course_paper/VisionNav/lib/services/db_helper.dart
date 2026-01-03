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
      version: 3, // v3: привязка помещений к пользователю + колонны
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

    // Таблица помещений (каждое помещение принадлежит пользователю)
    await db.execute('''
      CREATE TABLE rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        width REAL NOT NULL,
        depth REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    // Таблица колонн (препятствий) внутри помещения
    await db.execute('''
      CREATE TABLE columns (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        room_id INTEGER NOT NULL,
        from_front REAL NOT NULL,
        from_left REAL NOT NULL,
        width REAL NOT NULL,
        depth REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v2 -> v3: rooms.user_id + таблица колонн
    if (oldVersion < 2) {
      // Проект мог быть без rooms вообще
      await db.execute('''
        CREATE TABLE rooms (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL DEFAULT 0,
          width REAL NOT NULL,
          depth REAL NOT NULL,
          created_at TEXT NOT NULL
        );
      ''');
    }

    if (oldVersion < 3) {
      // Добавляем user_id в существующую таблицу rooms (если она была создана в v2 без user_id)
      final cols = await db.rawQuery("PRAGMA table_info(rooms);");
      final hasUserId = cols.any((c) => c['name'] == 'user_id');
      if (!hasUserId) {
        await db.execute(
          'ALTER TABLE rooms ADD COLUMN user_id INTEGER NOT NULL DEFAULT 0;',
        );
      }

      // Создаём таблицу колонн
      await db.execute('''
        CREATE TABLE IF NOT EXISTS columns (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          room_id INTEGER NOT NULL,
          from_front REAL NOT NULL,
          from_left REAL NOT NULL,
          width REAL NOT NULL,
          depth REAL NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE
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
