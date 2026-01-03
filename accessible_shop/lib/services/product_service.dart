import '../models/product.dart';

class ProductService {
  ProductService._internal();
  static final ProductService instance = ProductService._internal();

  // Каталог товаров Apple (данные локальные, без сети).
  // Цены заданы в рублях для демонстрации.
  final List<Product> _products = [
    // iPhone
    Product(id: 1, name: 'iPhone 16', category: 'iPhone', description: '128GB', price: 89990.0),
    Product(id: 2, name: 'iPhone 16 Plus', category: 'iPhone', description: '256GB', price: 109990.0),
    Product(id: 3, name: 'iPhone 16 Pro', category: 'iPhone', description: '128GB', price: 119990.0),
    Product(id: 4, name: 'iPhone 16 Pro Max', category: 'iPhone', description: '256GB', price: 139990.0),
    Product(id: 5, name: 'iPhone 15', category: 'iPhone', description: '128GB', price: 79990.0),
    Product(id: 6, name: 'iPhone 15 Plus', category: 'iPhone', description: '128GB', price: 89990.0),
    Product(id: 7, name: 'iPhone 15 Pro', category: 'iPhone', description: '256GB', price: 119990.0),
    Product(id: 8, name: 'iPhone 15 Pro Max', category: 'iPhone', description: '256GB', price: 129990.0),

    // iPad
    Product(id: 9, name: 'iPad 10', category: 'iPad', description: '64GB Wi‑Fi', price: 49990.0),
    Product(id: 10, name: 'iPad 10 Cellular', category: 'iPad', description: '64GB Wi‑Fi + Cellular', price: 59990.0),
    Product(id: 11, name: 'iPad Air 11', category: 'iPad', description: 'M2 128GB', price: 79990.0),
    Product(id: 12, name: 'iPad Air 13', category: 'iPad', description: 'M2 256GB', price: 99990.0),
    Product(id: 13, name: 'iPad Pro 11', category: 'iPad', description: 'M4 256GB', price: 129990.0),
    Product(id: 14, name: 'iPad Pro 13', category: 'iPad', description: 'M4 512GB', price: 169990.0),
    Product(id: 15, name: 'iPad mini', category: 'iPad', description: '256GB Wi‑Fi', price: 69990.0),

    // Mac
    Product(id: 20, name: 'MacBook Air 13', category: 'Mac', description: 'M2 8/256', price: 119990.0),
    Product(id: 21, name: 'MacBook Air 15', category: 'Mac', description: 'M2 8/512', price: 149990.0),
    Product(id: 22, name: 'MacBook Pro 14', category: 'Mac', description: 'M3 Pro 18/512', price: 249990.0),
    Product(id: 23, name: 'MacBook Pro 16', category: 'Mac', description: 'M3 Max 36/1TB', price: 399990.0),
    Product(id: 24, name: 'iMac 24', category: 'Mac', description: 'M3 8/256', price: 179990.0),
    Product(id: 25, name: 'Mac mini', category: 'Mac', description: 'M2 8/256', price: 79990.0),
    Product(id: 26, name: 'Mac Studio', category: 'Mac', description: 'M2 Max 32/512', price: 299990.0),

    // Apple Watch
    Product(id: 30, name: 'Apple Watch Series 10', category: 'Apple Watch', description: 'GPS 45mm', price: 49990.0),
    Product(id: 31, name: 'Apple Watch SE', category: 'Apple Watch', description: 'GPS 44mm', price: 29990.0),
    Product(id: 32, name: 'Apple Watch Ultra 2', category: 'Apple Watch', description: '49mm', price: 89990.0),

    // AirPods
    Product(id: 40, name: 'AirPods 4', category: 'AirPods', description: 'USB‑C', price: 17990.0),
    Product(id: 41, name: 'AirPods Pro 2', category: 'AirPods', description: 'USB‑C, шумоподавление', price: 27990.0),
    Product(id: 42, name: 'AirPods Max', category: 'AirPods', description: 'Беспроводные наушники', price: 64990.0),

    // Accessories
    Product(id: 50, name: 'MagSafe Charger', category: 'Accessories', description: 'Беспроводная зарядка', price: 6990.0),
    Product(id: 51, name: 'Apple Pencil (USB‑C)', category: 'Accessories', description: 'Для iPad', price: 9990.0),
    Product(id: 52, name: 'Smart Folio for iPad', category: 'Accessories', description: 'Чехол‑обложка', price: 12990.0),
    Product(id: 53, name: 'USB‑C Power Adapter 20W', category: 'Accessories', description: 'Адаптер питания', price: 2990.0),
  ];

  List<String> getCategories() {
    final categories = _products.map((p) => p.category).toSet().toList();
    categories.sort();
    return categories;
  }

  List<Product> getProductsByCategory(String category) {
    final items = _products.where((p) => p.category == category).toList();
    items.sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  /// Поиск по каталогу: имя / описание / категория.
  /// Возвращает отсортированный список.
  List<Product> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final results = _products.where((p) {
      final haystack = '${p.name} ${p.description} ${p.category}'.toLowerCase();
      return haystack.contains(q);
    }).toList();

    results.sort((a, b) => a.name.compareTo(b.name));
    return results;
  }

  List<Product> get allProducts => List.unmodifiable(_products);

  Product? getById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}