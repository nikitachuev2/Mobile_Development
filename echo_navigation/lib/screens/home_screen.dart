import 'package:flutter/material.dart';
import '../services/auth_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthRepository _authRepository = AuthRepository();
  String? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authRepository.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await _authRepository.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,   // нет кнопки "назад"
        leadingWidth: 0,                    // отключает скрытую area
        title: const Text('Echo Navigation — главная'),

        // ВАЖНО: полностью НЕТ системного overflow-меню
        actions: [
          Semantics(
            button: true,
            label: 'Выход из аккаунта',
            child: IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              tooltip: 'Выход из аккаунта',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentUser == null
                          ? 'Вы вошли в систему'
                          : 'Вы вошли как: $_currentUser',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Здесь позже будет экран выбора помещения, '
                        'задание размеров комнаты и координат пользователя, '
                        'а также переход к джойстику навигации и звуковым алгоритмам.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
