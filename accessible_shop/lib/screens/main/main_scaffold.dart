import 'package:flutter/material.dart';

import 'tabs/home_tab.dart';
import 'tabs/cart_tab.dart';
import 'tabs/profile_tab.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    CartTab(),
    ProfileTab(),
  ];

  static const List<String> _titles = [
    'Каталог',
    'Корзина',
    'Профиль',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: SafeArea(child: _tabs[_currentIndex]),
      bottomNavigationBar: Semantics(
        label:
            'Нижняя панель вкладок. Слева направо: Главная, Корзина, Личный кабинет.',
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Корзина',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}
