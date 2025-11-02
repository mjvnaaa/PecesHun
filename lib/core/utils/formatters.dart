import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double value) {
    if (value.abs() >= 1000000) {
      return NumberFormat.compactCurrency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 2,
      ).format(value);
    } else {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(value);
    }
  }

  static String formatDate(DateTime date) {
    final format = DateFormat('d MMM yyyy', 'id_ID');
    return format.format(date);
  }

  static String formatDateTime(DateTime date) {
    final format = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
    return format.format(date);
  }
}