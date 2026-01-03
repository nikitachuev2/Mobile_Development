import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../utils/accessibility.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  final bool showCheckoutButton;
  final int quantity;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.showCheckoutButton = false,
    this.quantity = 1,
  });

  Future<void> _handleAddToCart(BuildContext context) async {
    CartService.instance.addProduct(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} добавлен в корзину')),
    );
  }

  Future<void> _handleCheckout(BuildContext context) async {
    final q = quantity < 1 ? 1 : quantity;
    await OrderService.instance.placeOrderWithQuantity(product, q);
    CartService.instance.removeProduct(product);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Заказ успешно оформлен')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final priceText = formatPrice(product.price);
    final totalText = formatPrice(product.price * (quantity < 1 ? 1 : quantity));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Информация о товаре'),
      ),
      body: SafeArea(
        child: Semantics(
          label:
              'Экран подробной информации о товаре ${product.name}. Здесь можно прочитать описание и ${showCheckoutButton ? "оформить заказ" : "добавить товар в корзину"}.',
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Категория: ${product.category}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Цена: $priceText',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showCheckoutButton) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Количество: ${quantity < 1 ? 1 : quantity}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Итого за позицию: $totalText',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Описание:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => showCheckoutButton
                        ? _handleCheckout(context)
                        : _handleAddToCart(context),
                    child: Text(
                      showCheckoutButton
                          ? 'Оформить заказ'
                          : 'Добавить в корзину',
                    ),
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
