import '../models/user.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<bool> login(String username, String password) async {
    // Простая заглушка: любой непустой логин/пароль принимаем
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }
    _currentUser = AppUser(username: username.trim());
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
  }
}
