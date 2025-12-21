import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/accessibility.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priceText = formatPrice(product.price);

    return Semantics(
      button: true,
      label:
          '${product.name}, категория ${product.category}, цена $priceText. Двойной тап, чтобы открыть подробную информацию о товаре.',
      child: ListTile(
        title: Text(product.name),
        subtitle: Text(product.description),
        trailing: Text(priceText),
        onTap: onTap,
      ),
    );
  }
}
