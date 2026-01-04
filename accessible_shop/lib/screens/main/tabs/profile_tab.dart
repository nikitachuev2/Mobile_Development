import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../services/order_service.dart';
import '../../../models/order.dart';
import '../../../widgets/empty_state.dart';
import '../../../utils/accessibility.dart';
import '../../auth/login_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final OrderService _orderService = OrderService.instance;
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await _orderService.getUserOrders();
    if (!mounted) return;
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Личный кабинет'),
      ),
      body: SafeArea(
        child: Semantics(
          label:
              'Вкладка личный кабинет. Здесь информация о пользователе и история заказов.',
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user == null
                      ? 'Пользователь не авторизован'
                      : 'Вы вошли как: ${user.username}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _logout,
                  child: const Text('Выйти из аккаунта'),
                ),
                const SizedBox(height: 24),
                const Text(
                  'История заказов',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _orders.isEmpty
                          ? const EmptyState(
                              message:
                                  'У вас пока нет оформленных заказов.',
                            )
                          : ListView.builder(
                              itemCount: _orders.length,
                              itemBuilder: (context, index) {
                                final order = _orders[index];
                                final price = formatPrice(order.productPrice);
                                final dateText =
                                    formatDateTime(order.createdAt);
                                return ListTile(
                                  title: Text(order.productName),
                                  subtitle:
                                      Text('Цена: $price\nДата: $dateText'),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
