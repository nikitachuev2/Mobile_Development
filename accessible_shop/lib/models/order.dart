class Order {
  final int? id;
  final String username;
  final String productName;
  final double productPrice;
  final DateTime createdAt;

  Order({
    this.id,
    required this.username,
    required this.productName,
    required this.productPrice,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'product_name': productName,
      'product_price': productPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int?,
      username: map['username'] as String,
      productName: map['product_name'] as String,
      productPrice: (map['product_price'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
