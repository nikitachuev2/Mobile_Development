import '../db/order_dao.dart';
import '../models/order.dart';
import '../models/product.dart';
import 'auth_service.dart';

class OrderService {
  OrderService._internal();
  static final OrderService instance = OrderService._internal();

  final OrderDao _orderDao = OrderDao();

  Future<void> placeOrder(Product product) async {
    await placeOrderWithQuantity(product, 1);
  }

  /// Оформление заказа с учётом количества (без изменения схемы БД).
  /// В БД сохраняем:
  /// - productName: "<название> (xN)" при N > 1
  /// - productPrice: общая сумма за позицию
  Future<void> placeOrderWithQuantity(Product product, int quantity) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final q = quantity < 1 ? 1 : quantity;
    final name = q == 1 ? product.name : '${product.name} (x$q)';
    final order = Order(
      username: user.username,
      productName: name,
      productPrice: product.price * q,
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
