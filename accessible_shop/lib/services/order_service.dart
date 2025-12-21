import '../db/order_dao.dart';
import '../models/order.dart';
import '../models/product.dart';
import 'auth_service.dart';

class OrderService {
  OrderService._internal();
  static final OrderService instance = OrderService._internal();

  final OrderDao _orderDao = OrderDao();

  Future<void> placeOrder(Product product) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final order = Order(
      username: user.username,
      productName: product.name,
      productPrice: product.price,
      createdAt: DateTime.now(),
    );
    await _orderDao.insertOrder(order);
  }

  Future<List<Order>> getUserOrders() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return [];
    return _orderDao.getOrdersByUser(user.username);
  }
}
