// lib/core/utils/formatters.dart
import 'package:intl/intl.dart';

class Formatters {
  // Format angka ke mata uang (otomatis ringkas)
  static String formatCurrency(double value) {
    if (value.abs() >= 1000000) {
      // contoh: Rp 10.8M, Rp 487.6K
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