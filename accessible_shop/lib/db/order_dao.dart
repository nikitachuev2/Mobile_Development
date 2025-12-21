import 'package:sqflite/sqflite.dart';

import 'app_database.dart';
import '../models/order.dart';

class OrderDao {
  Database get _db => AppDatabase.instance.database;

  Future<int> insertOrder(Order order) async {
    return _db.insert('orders', order.toMap());
  }

  Future<List<Order>> getOrdersByUser(String username) async {
    final result = await _db.query(
      'orders',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'created_at DESC',
    );
    return result.map((row) => Order.fromMap(row)).toList();
  }
}
