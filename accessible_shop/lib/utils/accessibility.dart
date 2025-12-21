import 'package:intl/intl.dart';

String formatPrice(double price) {
  return '${price.toStringAsFixed(0)} ₽';
}

String formatDateTime(DateTime dt) {
  final formatter = DateFormat('dd.MM.yyyy HH:mm');
  return formatter.format(dt);
}
