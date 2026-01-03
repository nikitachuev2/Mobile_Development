import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../../models/order.dart';
import '../../../services/auth_service.dart';
import '../../../services/order_service.dart';
import '../../../utils/accessibility.dart';
import '../../../widgets/empty_state.dart';
import '../../auth/login_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final OrderService _orderService = OrderService.instance;

  List<Order> _orders = const [];
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
    final username = user?.username ?? 'Неизвестный пользователь';

    return Semantics(
      label:
          'Вкладка профиль. Здесь информация о пользователе и история заказов.',
      child: RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Semantics(
              header: true,
              child: Text(
                'Аккаунт',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      label: 'Вы вошли как $username',
                      child: Text(
                        'Вы вошли как: $username',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Выйти'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(
                'История заказов',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_orders.isEmpty)
              const EmptyState(
                message:
                    'У вас пока нет оформленных заказов. Откройте корзину и нажмите «Оформить заказ».',
              )
            else
              ..._orders.map((order) {
                final price = formatPrice(order.productPrice);
                final dateText = formatDateTime(order.createdAt);
                return Card(
                  child: ListTile(
                    title: Text(order.productName),
                    subtitle: Text('Сумма: $price\nДата: $dateText'),
                    isThreeLine: true,
                    onTap: () {
                      final dir = Directionality.of(context);
                      SemanticsService.announce(
                        'Заказ: ${order.productName}. Сумма: $price. Дата: $dateText',
                        dir,
                      );
                    },
                  ),
                );
              }),
            const SizedBox(height: 8),
            Semantics(
              label:
                  'Чтобы обновить историю заказов, потяните список вниз.',
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
