import 'package:flutter/material.dart';

import '../services/auth_repository.dart';
import '../widgets/app_text_field.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;

  // Флажок "Показать пароль"
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Введите электронную почту.';
    }
    if (!text.contains('@') || !text.contains('.')) {
      return 'Введите корректную электронную почту.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Введите пароль.';
    }
    if (text.length < 6) {
      return 'Пароль должен содержать не менее 6 символов.';
    }
    return null;
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authRepository.login(
        _emailController.text,
        _passwordController.text,
      );

      if (user == null || user.id == null) {
        throw Exception('Не удалось получить данные пользователя.');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Вход выполнен успешно. Добро пожаловать!'),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            userId: user.id!,
            userEmail: user.email,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goToRegister() {
    Navigator.pushReplacementNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход в приложение'),
      ),
      body: SafeArea(
        child: Semantics(
          label: 'Экран входа в приложение',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16.0),
                  Text(
                    'Добро пожаловать!',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Введите свои данные для входа в систему.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24.0),
                  AppTextField(
                    controller: _emailController,
                    label: 'Электронная почта',
                    hint: 'Введите адрес электронной почты',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16.0),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Пароль',
                    hint: 'Введите пароль',
                    obscureText: !_showPassword,
                    validator: _validatePassword,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 8.0),
                  CheckboxListTile(
                    value: _showPassword,
                    onChanged: (value) {
                      setState(() {
                        _showPassword = value ?? false;
                      });
                    },
                    title: const Text('Показать пароль'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 24.0),
                  Semantics(
                    button: true,
                    label: _isLoading
                        ? 'Кнопка входа. Выполняется вход.'
                        : 'Кнопка входа в аккаунт',
                    child: SizedBox(
                      width: double.infinity,
                      height: 48.0,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onLoginPressed,
                        child: _isLoading
                            ? const CircularProgressIndicator.adaptive()
                            : const Text('Войти в аккаунт'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Semantics(
                    button: true,
                    label:
                        'Кнопка для перехода на экран регистрации нового пользователя',
                    child: TextButton(
                      onPressed: _isLoading ? null : _goToRegister,
                      child: const Text('У меня ещё нет аккаунта'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
