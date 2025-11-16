import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Очень простое локальное хранилище пользователей.
/// Пользователи хранятся как словарь: логин -> пароль.
///
/// В реальном приложении тут могла бы быть SQLite / сервер и т.п.
class AuthRepository {
  static const String _usersKey = 'auth_users';
  static const String _currentUserKey = 'auth_current_user';

  /// Загружает всех пользователей из shared_preferences.
  Future<Map<String, String>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_usersKey);
    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }
    final Map<String, dynamic> decoded = jsonDecode(jsonString);
    return decoded.map(
      (key, value) => MapEntry(key, value.toString()),
    );
  }

  /// Сохраняет словарь пользователей.
  Future<void> _saveUsers(Map<String, String> users) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(users);
    await prefs.setString(_usersKey, jsonString);
  }

  /// Регистрация нового пользователя.
  /// Возвращает true, если успешно, false если логин уже существует.
  Future<bool> register(String login, String password) async {
    final trimmedLogin = login.trim();
    final trimmedPassword = password.trim();

    if (trimmedLogin.isEmpty || trimmedPassword.isEmpty) {
      return false;
    }

    final users = await _loadUsers();
    if (users.containsKey(trimmedLogin)) {
      // пользователь с таким логином уже есть
      return false;
    }

    users[trimmedLogin] = trimmedPassword;
    await _saveUsers(users);
    return true;
  }

  /// Проверка логина и пароля.
  /// Возвращает true при успехе.
  Future<bool> login(String login, String password) async {
    final trimmedLogin = login.trim();
    final trimmedPassword = password.trim();

    final users = await _loadUsers();
    final storedPassword = users[trimmedLogin];

    final isValid = storedPassword != null && storedPassword == trimmedPassword;
    if (isValid) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, trimmedLogin);
    }
    return isValid;
  }

  /// Возвращает имя текущего вошедшего пользователя (или null).
  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  /// Выход из аккаунта.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
}
