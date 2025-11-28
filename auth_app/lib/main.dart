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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18.0),
          bodyMedium: TextStyle(fontSize: 16.0),
          titleLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
