import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'screens/main/main_scaffold.dart';
import 'services/auth_service.dart';
import 'db/app_database.dart';
import 'utils/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.init();
  runApp(const AccessibleShopApp());
}

class AccessibleShopApp extends StatelessWidget {
  const AccessibleShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accessible Shop',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/main': (_) => const MainScaffold(),
      },
    );
  }
}
