// lib/providers/analysis_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apkpribadi/data/models/transaction_model.dart';
import 'package:apkpribadi/providers/transaction_provider.dart';

final advancedAnalysisProvider = Provider<Map<String, dynamic>>((ref) {
  final transactions = ref.watch(transactionListProvider);

  if (transactions.isEmpty) {
    return {
      'highestCategory': 'Belum ada data',
      'averageExpensePerDay': 0.0,
      'totalDaysTracked': 0,
      'trend': 'stabil',
    };
  }

  // Hanya pengeluaran
  final expenses = transactions.where((t) => t.type == TransactionType.expense);

  // Grouping kategori
  final categoryTotals = <String, double>{};
  for (var tx in expenses) {
    categoryTotals[tx.category] =
        (categoryTotals[tx.category] ?? 0) + tx.amount;
  }

  // Kategori terbesar
  final highestCategory = categoryTotals.isNotEmpty
      ? categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key
      : 'Belum ada';

  // Hitung rentang hari data
  final dates = transactions.map((tx) => tx.date).toList()..sort();
  final daysTracked =
      dates.isEmpty ? 0 : dates.last.difference(dates.first).inDays + 1;

  // Rata-rata pengeluaran harian
  final totalExpense = expenses.fold(0.0, (sum, t) => sum + t.amount);
  final avgExpensePerDay =
      daysTracked > 0 ? totalExpense / daysTracked : totalExpense;

  // Hitung tren mingguan
  final sortedTx = expenses.toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  final recent7 = sortedTx.where((tx) =>
      tx.date.isAfter(DateTime.now().subtract(const Duration(days: 7))));
  final prev7 = sortedTx.where((tx) =>
      tx.date.isAfter(DateTime.now().subtract(const Duration(days: 14))) &&
      tx.date.isBefore(DateTime.now().subtract(const Duration(days: 7))));

  final recentTotal = recent7.fold(0.0, (s, tx) => s + tx.amount);
  final prevTotal = prev7.fold(0.0, (s, tx) => s + tx.amount);

  String trend;
  if (recentTotal > prevTotal * 1.1) {
    trend = 'naik';
  } else if (recentTotal < prevTotal * 0.9) {
    trend = 'turun';
  } else {
    trend = 'stabil';
  }

  return {
    'highestCategory': highestCategory,
    'averageExpensePerDay': avgExpensePerDay,
    'totalDaysTracked': daysTracked,
    'trend': trend,
  };
});