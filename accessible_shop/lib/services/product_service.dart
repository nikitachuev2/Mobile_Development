import '../models/product.dart';

class ProductService {
  ProductService._internal();
  static final ProductService instance = ProductService._internal();

  final List<Product> _products = [
    // iPhone
    Product(id: 1, name: 'iPhone 16', category: 'iPhone', description: 'iPhone 16 128GB', price: 89990),
    Product(id: 2, name: 'iPhone 16 Plus', category: 'iPhone', description: 'iPhone 16 Plus 256GB', price: 109990),
    Product(id: 3, name: 'iPhone 16 Pro', category: 'iPhone', description: 'iPhone 16 Pro 128GB', price: 119990),
    Product(id: 4, name: 'iPhone 16 Pro Max', category: 'iPhone', description: 'iPhone 16 Pro Max 256GB', price: 139990),
    Product(id: 5, name: 'iPhone 15', category: 'iPhone', description: 'iPhone 15 128GB', price: 79990),
    Product(id: 6, name: 'iPhone 15 Plus', category: 'iPhone', description: 'iPhone 15 Plus 128GB', price: 89990),
    Product(id: 7, name: 'iPhone 15 Pro', category: 'iPhone', description: 'iPhone 15 Pro 256GB', price: 119990),
    Product(id: 8, name: 'iPhone 15 Pro Max', category: 'iPhone', description: 'iPhone 15 Pro Max 256GB', price: 129990),

    // iPad
    Product(id: 9, name: 'iPad 10', category: 'iPad', description: 'iPad 10-го поколения 64GB Wi-Fi', price: 49990),
    Product(id: 10, name: 'iPad 10 Cellular', category: 'iPad', description: 'iPad 10-го поколения 64GB Wi-Fi + Cellular', price: 59990),
    Product(id: 11, name: 'iPad Air 11', category: 'iPad', description: 'iPad Air 11" M2 128GB', price: 79990),
    Product(id: 12, name: 'iPad Air 13', category: 'iPad', description: 'iPad Air 13" M2 256GB', price: 99990),
    Product(id: 13, name: 'iPad Pro 11', category: 'iPad', description: 'iPad Pro 11" M4 256GB', price: 129990),
    Product(id: 14, name: 'iPad Pro 13', category: 'iPad', description: 'iPad Pro 13" M4 512GB', price: 169990),

    // MacBook
    Product(id: 15, name: 'MacBook Air 13 M2', category: 'Mac', description: 'MacBook Air 13" M2 8/256', price: 119990),
    Product(id: 16, name: 'MacBook Air 15 M2', category: 'Mac', description: 'MacBook Air 15" M2 8/512', price: 149990),
    Product(id: 17, name: 'MacBook Pro 14 M3', category: 'Mac', description: 'MacBook Pro 14" M3 16/512', price: 199990),
    Product(id: 18, name: 'MacBook Pro 16 M3 Pro', category: 'Mac', description: 'MacBook Pro 16" M3 Pro 16/1TB', price: 269990),

    // Apple Watch
    Product(id: 19, name: 'Apple Watch Series 10 41mm', category: 'Watch', description: 'Apple Watch Series 10 41 мм', price: 39990),
    Product(id: 20, name: 'Apple Watch Series 10 45mm', category: 'Watch', description: 'Apple Watch Series 10 45 мм', price: 44990),
    Product(id: 21, name: 'Apple Watch SE 40mm', category: 'Watch', description: 'Apple Watch SE 40 мм', price: 27990),
    Product(id: 22, name: 'Apple Watch SE 44mm', category: 'Watch', description: 'Apple Watch SE 44 мм', price: 31990),
    Product(id: 23, name: 'Apple Watch Ultra 2', category: 'Watch', description: 'Apple Watch Ultra 2 49 мм', price: 79990),

    // AirPods
    Product(id: 24, name: 'AirPods 3', category: 'AirPods', description: 'AirPods 3-го поколения', price: 19990),
    Product(id: 25, name: 'AirPods Pro 2 USB-C', category: 'AirPods', description: 'AirPods Pro 2 с USB-C', price: 25990),
    Product(id: 26, name: 'AirPods Max', category: 'AirPods', description: 'AirPods Max', price: 59990),

    // Accessories
    Product(id: 27, name: 'Apple Pencil Pro', category: 'Accessories', description: 'Apple Pencil Pro для iPad', price: 14990),
    Product(id: 28, name: 'Apple Pencil USB-C', category: 'Accessories', description: 'Apple Pencil USB-C', price: 9990),
    Product(id: 29, name: 'MagSafe Charger', category: 'Accessories', description: 'Зарядное устройство MagSafe', price: 5990),
    Product(id: 30, name: 'MagSafe Duo Charger', category: 'Accessories', description: 'Зарядное устройство MagSafe Duo', price: 11990),
    Product(id: 31, name: 'Magic Keyboard для iPad Pro 11', category: 'Accessories', description: 'Magic Keyboard для iPad Pro 11"', price: 29990),
    Product(id: 32, name: 'Magic Keyboard для iPad Pro 13', category: 'Accessories', description: 'Magic Keyboard для iPad Pro 13"', price: 34990),

    // ещё немного для набора до ~40
    Product(id: 33, name: 'iPhone 14', category: 'iPhone', description: 'iPhone 14 128GB', price: 69990),
    Product(id: 34, name: 'iPhone 14 Pro', category: 'iPhone', description: 'iPhone 14 Pro 256GB', price: 99990),
    Product(id: 35, name: 'iPad mini 6', category: 'iPad', description: 'iPad mini 6 64GB', price: 59990),
    Product(id: 36, name: 'Mac mini M2', category: 'Mac', description: 'Mac mini M2 8/256', price: 79990),
    Product(id: 37, name: 'Studio Display', category: 'Mac', description: 'Apple Studio Display 27"', price: 199990),
    Product(id: 38, name: 'Apple TV 4K', category: 'Accessories', description: 'Apple TV 4K 128GB', price: 17990),
    Product(id: 39, name: 'AirTag (4 штуки)', category: 'Accessories', description: 'Набор AirTag 4 шт.', price: 11990),
    Product(id: 40, name: 'Beats Studio Pro', category: 'AirPods', description: 'Наушники Beats Studio Pro', price: 29990),
  ];

  List<String> getCategories() {
    final set = _products.map((p) => p.category).toSet();
    final list = set.toList()..sort();
    return list;
  }

  List<Product> getProductsByCategory(String category) {
    // Возвращаем копию, чтобы внешний код не мог мутировать внутренний список.
    return _products.where((p) => p.category == category).toList(growable: false);
  }

  List<Product> get allProducts => List.unmodifiable(_products);

  Product? getById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // ДОБАВЛЕНО: Поиск товаров (не ломает существующий код)
  // ---------------------------------------------------------------------------

  /// Возвращает результаты поиска по товарам.
  ///
  /// Ищем по: name + description + category.
  /// - регистр не важен
  /// - множественные пробелы игнорируются
  /// - запрос может быть из нескольких слов: все слова должны встречаться (AND)
  ///
  /// Если query пустой/из пробелов — возвращает пустой список.
  List<Product> searchProducts(String query) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) return const <Product>[];

    final tokens = normalizedQuery.split(' ').where((t) => t.isNotEmpty).toList(growable: false);
    if (tokens.isEmpty) return const <Product>[];

    bool matches(Product p) {
      final haystack = _normalize('${p.name} ${p.description} ${p.category}');
      // AND: каждый токен должен встречаться
      return tokens.every(haystack.contains);
    }

    final results = _products.where(matches).toList(growable: false);
    if (results.isEmpty) return const <Product>[];

    // Сортировка по релевантности (простая и стабильная):
    // 1) name содержит полный запрос
    // 2) description содержит полный запрос
    // 3) затем по алфавиту name
    int score(Product p) {
      final name = _normalize(p.name);
      final desc = _normalize(p.description);
      if (name.contains(normalizedQuery)) return 0;
      if (desc.contains(normalizedQuery)) return 1;
      return 2;
    }

    final sorted = results.toList(growable: true);
    sorted.sort((a, b) {
      final sa = score(a);
      final sb = score(b);
      if (sa != sb) return sa.compareTo(sb);
      return a.name.compareTo(b.name);
    });

    return List.unmodifiable(sorted);
  }

  String _normalize(String s) {
    return s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}
