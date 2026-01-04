import 'package:flutter/material.dart';

import '../../../services/product_service.dart';
import '../../../widgets/category_header.dart';
import '../../../widgets/product_card.dart';
import '../../product_details_screen.dart';
import '../../../models/product.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final productService = ProductService.instance;
    final categories = productService.getCategories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Магазин электроники'),
      ),
      body: Semantics(
        label:
            'Главная вкладка. Список категорий товаров и товары Apple. Выберите товар, чтобы открыть подробную информацию и добавить его в корзину.',
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final products =
                productService.getProductsByCategory(category);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryHeader(title: category),
                ...products.map((Product product) {
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsScreen(
                            product: product,
                            showCheckoutButton: false,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ),
    );
  }
}
