class AppUser {
  final String email;

  AppUser({required this.email});

  /// Для обратной совместимости со старым кодом
  String get username => email;
}
