import 'package:flutter/material.dart';

import '../services/auth_repository.dart';
import '../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
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

  String? _validatePasswordConfirm(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Повторите пароль.';
    }
    if (text != _passwordController.text.trim()) {
      return 'Пароли не совпадают.';
    }
    return null;
  }

  Future<void> _onRegisterPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authRepository.register(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Регистрация прошла успешно. Теперь вы можете войти в аккаунт.',
          ),
        ),
      );

      Navigator.pushReplacementNamed(context, '/login');
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

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
      ),
      body: SafeArea(
        child: Semantics(
          label: 'Экран регистрации нового пользователя',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16.0),
                  Text(
                    'Создание аккаунта',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Заполните поля, чтобы зарегистрировать новый аккаунт.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24.0),
                  AppTextField(
                    controller: _emailController,
                    label: 'Электронная почта',
                    hint: 'Введите адрес электронной почты',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16.0),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Пароль',
                    hint: 'Придумайте пароль (не менее 6 символов)',
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 16.0),
                  AppTextField(
                    controller: _passwordConfirmController,
                    label: 'Повтор пароля',
                    hint: 'Повторите пароль',
                    obscureText: true,
                    validator: _validatePasswordConfirm,
                  ),
                  const SizedBox(height: 24.0),
                  Semantics(
                    button: true,
                    label: _isLoading
                        ? 'Кнопка регистрации. Выполняется создание аккаунта.'
                        : 'Кнопка регистрации нового пользователя',
                    child: SizedBox(
                      width: double.infinity,
                      height: 48.0,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onRegisterPressed,
                        child: _isLoading
                            ? const CircularProgressIndicator.adaptive()
                            : const Text('Зарегистрироваться'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Semantics(
                    button: true,
                    label:
                        'Кнопка для перехода на экран входа, если у вас уже есть аккаунт',
                    child: TextButton(
                      onPressed: _isLoading ? null : _goToLogin,
                      child: const Text('У меня уже есть аккаунт'),
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
