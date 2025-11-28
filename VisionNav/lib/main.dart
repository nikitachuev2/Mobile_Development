import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'services/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.instance.initDb();

  runApp(const AuthApp());
}

class AuthApp extends StatelessWidget {
  const AuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Авторизация',
      debugShowCheckedModeBanner: false,

      // ------------------------------
      //         Т Е М А   П Р И Л О Ж Е Н И Я
      // ------------------------------
      theme: ThemeData(
        useMaterial3: true,

        // Глобальная цветовая схема – светлая, iOS-серые оттенки
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.light,
        ),

        // Цвет фона приложения
        scaffoldBackgroundColor: Colors.grey.shade100,

        // ------------------------------
        //     ELEVATED BUTTON (основная кнопка)
        // ------------------------------
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300, // iOS – светлый серый
            foregroundColor: Colors.black87,
            disabledBackgroundColor: Colors.grey.shade200,
            disabledForegroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0, // стиль iOS — без тени
          ),
        ),

        // ------------------------------
        //     TEXT BUTTON (обычные ссылки)
        // ------------------------------
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),

        // ------------------------------
        //     OUTLINED BUTTON
        // ------------------------------
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade400),
            foregroundColor: Colors.grey.shade800,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // ------------------------------
        //    ТЕКСТЫ В ПРИЛОЖЕНИИ
        // ------------------------------
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18.0),
          bodyMedium: TextStyle(fontSize: 16.0),
          titleLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),

      // ------------------------------
      //         М А Р Ш Р У Т Ы
      // ------------------------------
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
