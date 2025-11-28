import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user.dart';
import 'db_helper.dart';

class AuthRepository {
  AuthRepository._internal();
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;

  final DBHelper _dbHelper = DBHelper.instance;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> register(String email, String password) async {
    final db = _dbHelper.database;

    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.trim().isEmpty) {
      throw Exception('Электронная почта и пароль не могут быть пустыми.');
    }

    // Проверка, что пользователя с таким email ещё нет
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      throw Exception('Пользователь с такой электронной почтой уже существует.');
    }

    final passwordHash = _hashPassword(password);
    final now = DateTime.now().toIso8601String();

    final user = User(
      email: normalizedEmail,
      passwordHash: passwordHash,
      createdAt: now,
    );

    final id = await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);

    return user.copyWith(id: id);
  }

  Future<User?> login(String email, String password) async {
    final db = _dbHelper.database;

    final normalizedEmail = email.trim().toLowerCase();
    final passwordHash = _hashPassword(password);

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );

    if (result.isEmpty) {
      throw Exception('Пользователь с такой электронной почтой не найден.');
    }

    final user = User.fromMap(result.first);

    if (user.passwordHash != passwordHash) {
      throw Exception('Неверный пароль.');
    }

    return user;
  }
}

extension on User {
  User copyWith({
    int? id,
    String? email,
    String? passwordHash,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
