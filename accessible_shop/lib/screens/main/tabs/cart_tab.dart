import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../../services/cart_service.dart';
import '../../../services/order_service.dart';
import '../../../utils/accessibility.dart';
import '../../../widgets/empty_state.dart';
import '../../product_details_screen.dart';

class CartTab extends StatefulWidget {
  const CartTab({super.key});

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  final CartService _cartService = CartService.instance;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _checkoutAll() async {
    if (_cartService.items.isEmpty) return;

    setState(() => _isSubmitting = true);

    for (final item in _cartService.items) {
      await OrderService.instance
          .placeOrderWithQuantity(item.product, item.quantity);
    }

    _cartService.clearCart();

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final dir = Directionality.of(context);
    SemanticsService.announce('Заказ оформлен', dir);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Заказ успешно оформлен')),
    );
  }

  void _clearCart() {
    _cartService.clearCart();
    final dir = Directionality.of(context);
    SemanticsService.announce('Корзина очищена', dir);
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartService.items;
    final total = formatPrice(_cartService.getTotalPrice());

    return Semantics(
      label:
          'Вкладка корзина. Здесь отображаются добавленные товары. Можно изменить количество, удалить товары или оформить заказ.',
      child: items.isEmpty
          ? const EmptyState(message: 'Корзина пуста.')
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          label: 'Итого к оплате $total',
                          child: Text(
                            'Итого: $total',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _clearCart,
                        tooltip: 'Очистить корзину',
                        icon: const Icon(Icons.delete_sweep),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final lineTotal =
                          formatPrice(item.product.price * item.quantity);

                      return Card(
                        child: ListTile(
                          title: Text(item.product.name),
                          subtitle: Text(
                            'Количество: ${item.quantity}. Сумма: $lineTotal',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(
                                  product: item.product,
                                  showCheckoutButton: true,
                                  quantity: item.quantity,
                                ),
                              ),
                            );
                          },
                          trailing: SizedBox(
                            width: 132,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  tooltip: 'Уменьшить количество',
                                  onPressed: () =>
                                      _cartService.decrement(item.product),
                                  icon: const Icon(Icons.remove),
                                ),
                                Semantics(
                                  label: 'Количество ${item.quantity}',
                                  child: Text(
                                    '${item.quantity}',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Увеличить количество',
                                  onPressed: () =>
                                      _cartService.increment(item.product),
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _checkoutAll,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle),
                      label: const Text('Оформить заказ'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
