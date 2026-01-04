import 'package:flutter/material.dart';

import '../../../services/cart_service.dart';
import '../../../widgets/empty_state.dart';
import '../../../utils/accessibility.dart';
import '../../product_details_screen.dart';

class CartTab extends StatefulWidget {
  const CartTab({super.key});

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  final CartService _cartService = CartService.instance;

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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartService.items;
    final total = formatPrice(_cartService.getTotalPrice());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
      ),
      body: Semantics(
        label:
            'Вкладка корзина. Здесь отображаются добавленные товары. Нажмите на товар, чтобы открыть подробную информацию и оформить заказ.',
        child: items.isEmpty
            ? const EmptyState(message: 'Корзина пуста.')
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final priceText =
                            formatPrice(item.product.price * item.quantity);

                        return ListTile(
                          title: Text(item.product.name),
                          subtitle: Text(
                              'Количество: ${item.quantity}. Цена: $priceText'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(
                                  product: item.product,
                                  showCheckoutButton: true,
                                ),
                              ),
                            );
                          },
                          trailing: Semantics(
                            button: true,
                            label:
                                'Удалить товар ${item.product.name} из корзины',
                            hint: 'Двойное нажатие удалит товар',
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Удалить из корзины',
                              onPressed: () {
                                _cartService.removeProduct(item.product);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Semantics(
                      label: 'Итого к оплате $total',
                      child: Text(
                        'Итого: $total',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
