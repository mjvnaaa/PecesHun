// lib/providers/transaction_provider.dart
import 'package:apkpribadi/data/models/transaction_model.dart';
import 'package:apkpribadi/data/repository/transaction_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// 1. Provider untuk Repository
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl();
});

// 2. Provider untuk StateNotifier (mengelola list transaksi)
final transactionListProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(repository);
});

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  final TransactionRepository _repository;

  TransactionNotifier(this._repository) : super([]) {
    // Langsung muat data saat Notifier dibuat
    loadTransactions();

    // Dengarkan perubahan pada Hive Box
    _repository.getTransactionBox().watch().listen((event) {
      // Jika ada perubahan (tambah/hapus/edit), muat ulang data
      loadTransactions();
    });
  }

  void loadTransactions() {
    state = _repository.getAllTransactions();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _repository.addTransaction(transaction);
    // state akan ter-update otomatis oleh listener di constructor
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _repository.updateTransaction(transaction);
  }
}

// 3. Provider turunan (derived state) untuk Dashboard Metrics
final dashboardMetricsProvider = Provider<Map<String, double>>((ref) {
  // Ambil list transaksi dari provider utama
  final transactions = ref.watch(transactionListProvider);

  double totalIncome = 0;
  double totalExpense = 0;

  for (final tx in transactions) {
    if (tx.type == TransactionType.income) {
      totalIncome += tx.amount;
    } else {
      totalExpense += tx.amount;
    }
  }

  return {
    'income': totalIncome,
    'expense': totalExpense,
    'balance': totalIncome - totalExpense,
  };
});

// 4. Provider turunan untuk data Pie Chart
final pieChartDataProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(transactionListProvider);
  Map<String, double> categoryMap = {};

  // Hanya ambil data pengeluaran
  final expenses =
      transactions.where((tx) => tx.type == TransactionType.expense);

  if (expenses.isEmpty) {
    return {'Belum ada data': 1}; // Data dummy jika kosong
  }

  for (final tx in expenses) {
    if (categoryMap.containsKey(tx.category)) {
      categoryMap[tx.category] = categoryMap[tx.category]! + tx.amount;
    } else {
      categoryMap[tx.category] = tx.amount;
    }
  }

  return categoryMap;
});