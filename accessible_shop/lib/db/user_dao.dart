import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

class UserDao {
  Database get _db => AppDatabase.instance.database;

  Future<int> insertUser({
    required String email,
    required String passwordHash,
    required String salt,
    required String createdAt,
  }) {
    return _db.insert('users', {
      'email': email,
      'password_hash': passwordHash,
      'salt': salt,
      'created_at': createdAt,
    });
  }

  Future<Map<String, Object?>?> getUserByEmail(String email) {
    return _db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    ).then((rows) => rows.isEmpty ? null : rows.first);
  }
}
