import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../utils/accessibility.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  final bool showCheckoutButton;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.showCheckoutButton,
  });

  Future<void> _handleAddToCart(BuildContext context) async {
    CartService.instance.addProduct(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} добавлен в корзину')),
    );
  }

  Future<void> _handleCheckout(BuildContext context) async {
    await OrderService.instance.placeOrder(product);
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
