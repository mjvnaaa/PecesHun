// lib/core/utils/formatters.dart
import 'package:intl/intl.dart';

class Formatters {
  // Format mata uang Rupiah
  static String formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  // Format tanggal
  static String formatDate(DateTime date) {
    final format = DateFormat('d MMM yyyy', 'id_ID');
    return format.format(date);
  }

  // Format tanggal dan jam
  static String formatDateTime(DateTime date) {
    final format = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
    return format.format(date);
  }
}