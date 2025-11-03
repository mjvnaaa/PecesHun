import 'package:apkpribadi/data/models/transaction_model.dart';
import 'package:apkpribadi/data/repository/transaction_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl();
});

final transactionListProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(repository);
});

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  final TransactionRepository _repository;

  TransactionNotifier(this._repository) : super([]) {
    loadTransactions();
    _repository.getTransactionBox().watch().listen((event) {
      loadTransactions();
    });
  }

  void loadTransactions() {
    state = _repository.getAllTransactions();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _repository.addTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);
  }

  Future<void> deleteTransactionDataOnly(String id) async {
    await _repository.deleteTransactionDataOnly(id);
  }

  Future<void> deleteAttachmentFile(TransactionModel transaction) async {
    await _repository.deleteAttachmentFile(transaction);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _repository.updateTransaction(transaction);
  }
}

final dashboardMetricsProvider = Provider<Map<String, double>>((ref) {
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

final pieChartDataProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(transactionListProvider);
  Map<String, double> categoryMap = {};

  final expenses =
      transactions.where((tx) => tx.type == TransactionType.expense);

  if (expenses.isEmpty) {
    return {'Belum ada data': 1};
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