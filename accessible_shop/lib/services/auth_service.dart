import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../db/app_database.dart';
import '../models/user.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  /// ВХОД
  Future<bool> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      return false;
    }

    final db = AppDatabase.instance.database;

    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );

    if (rows.isEmpty) return false;

    final row = rows.first;
    final salt = row['salt'] as String;
    final storedHash = row['password_hash'] as String;

    final inputHash = _hashPassword(password, salt);
    if (inputHash != storedHash) return false;

    _currentUser = AppUser(email: normalizedEmail);
    return true;
  }

  /// РЕГИСТРАЦИЯ
  Future<bool> register(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      return false;
    }

    final db = AppDatabase.instance.database;

    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return false; // пользователь уже существует
    }

    final salt = _generateSalt();
    final hash = _hashPassword(password, salt);

    await db.insert('users', {
      'email': normalizedEmail,
      'password_hash': hash,
      'salt': salt,
      'created_at': DateTime.now().toIso8601String(),
    });

    _currentUser = AppUser(email: normalizedEmail);
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  // ===== helpers =====

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt::$password');
    return sha256.convert(bytes).toString();
  }

  String _generateSalt() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    return base64UrlEncode(bytes);
  }
}
