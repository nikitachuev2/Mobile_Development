import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../../models/product.dart';
import '../../../services/product_service.dart';
import '../../../widgets/category_header.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/product_card.dart';
import '../../product_details_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
    // Озвучить очистку для скринридера.
    final dir = Directionality.of(context);
    SemanticsService.announce('Поиск очищен', dir);
    _searchFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final productService = ProductService.instance;

    final query = _query.trim();
    final isSearching = query.isNotEmpty;

    final List<Product> searchResults =
        isSearching ? productService.search(query) : const [];

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Semantics(
              textField: true,
              label: 'Поиск товара',
              hint: 'Введите название, категорию или характеристики. Например: iPhone, AirPods, M2',
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                textInputAction: TextInputAction.search,
                onChanged: (value) => setState(() => _query = value),
                onSubmitted: (_) => _searchFocus.unfocus(),
                decoration: InputDecoration(
                  labelText: 'Поиск',
                  hintText: 'Например: iPhone 16 Pro',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: isSearching
                      ? IconButton(
                          tooltip: 'Очистить поиск',
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ),
          Expanded(
            child: isSearching
                ? _SearchResultsList(
                    query: query,
                    results: searchResults,
                    onOpenProduct: (product) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsScreen(product: product),
                        ),
                      );
                    },
                  )
                : _CategoriesList(
                    categories: productService.getCategories(),
                    productService: productService,
                    onOpenProduct: (product) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsScreen(product: product),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  final String query;
  final List<Product> results;
  final void Function(Product product) onOpenProduct;

  const _SearchResultsList({
    required this.query,
    required this.results,
    required this.onOpenProduct,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: EmptyState(
          message: 'Ничего не найдено. Попробуйте другое название или категорию.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Semantics(
          header: true,
          child: Text(
            'Результаты: ${results.length}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        ...results.map((product) {
          return ProductCard(
            product: product,
            onTap: () => onOpenProduct(product),
          );
        }),
      ],
    );
  }
}

class _CategoriesList extends StatelessWidget {
  final List<String> categories;
  final ProductService productService;
  final void Function(Product product) onOpenProduct;

  const _CategoriesList({
    required this.categories,
    required this.productService,
    required this.onOpenProduct,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final products = productService.getProductsByCategory(category);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryHeader(title: category),
            ...products.map((product) {
              return ProductCard(
                product: product,
                onTap: () => onOpenProduct(product),
              );
            }),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
