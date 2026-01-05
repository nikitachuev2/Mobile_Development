import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../services/product_service.dart';
import '../../../widgets/category_header.dart';
import '../../../widgets/product_card.dart';
import '../../product_details_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);

    // debounce нужен, чтобы список не дергался слишком часто на слабых девайсах
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      // Ничего не делаем тут специально — список и так обновится через setState.
      // Для скринридера состояние списка будет доступно через liveRegion ниже.
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() => _query = '');
    _searchFocusNode.requestFocus();
  }

  void _openProduct(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          product: product,
          showCheckoutButton: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productService = ProductService.instance;
    final categories = productService.getCategories();

    final trimmedQuery = _query.trim();
    final isSearching = trimmedQuery.isNotEmpty;

    final searchResults = isSearching
        ? productService.searchProducts(trimmedQuery)
        : const <Product>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Магазин электроники'),
      ),
      body: Column(
        children: [
          // --- Поиск сверху ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Semantics(
              textField: true,
              label: 'Поиск товаров',
              hint: 'Введите название, описание или категорию. '
                  'Ниже появятся результаты.',
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onQueryChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Поиск товаров',
                  hintText: 'Например: iPhone, iPad, AirPods',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: isSearching
                      ? IconButton(
                          onPressed: _clearSearch,
                          tooltip: 'Очистить поиск',
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ),

          // --- Контент ниже ---
          Expanded(
            child: isSearching
                ? _SearchResults(
                    query: trimmedQuery,
                    results: searchResults,
                    onTap: (p) => _openProduct(context, p),
                  )
                : ListView.builder(
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
                              onTap: () => _openProduct(context, product),
                            );
                          }).toList(),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final String query;
  final List<Product> results;
  final ValueChanged<Product> onTap;

  const _SearchResults({
    required this.query,
    required this.results,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // liveRegion: скринридер заметит смену состояния (кол-во результатов/пусто)
    return Semantics(
      liveRegion: true,
      label: results.isEmpty
          ? 'Ничего не найдено по запросу: $query.'
          : 'Результаты поиска по запросу: $query. Найдено: ${results.length}.',
      child: results.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('Ничего не найдено'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Semantics(
                  header: true,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Результаты (${results.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                ...results.map(
                  (p) => ProductCard(
                    product: p,
                    onTap: () => onTap(p),
                  ),
                ),
              ],
            ),
    );
  }
}
