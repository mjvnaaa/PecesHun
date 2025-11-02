import 'dart:developer';
import 'dart:io';
import 'package:apkpribadi/core/constants.dart';
import 'package:apkpribadi/data/models/transaction_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class TransactionRepository {
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<void> updateTransaction(TransactionModel transaction);
  List<TransactionModel> getAllTransactions();
  Box<TransactionModel> getTransactionBox();
}

class TransactionRepositoryImpl implements TransactionRepository {
  final Box<TransactionModel> _transactionBox;

  TransactionRepositoryImpl()
      : _transactionBox = Hive.box<TransactionModel>(kTransactionBox);

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      final transaction = _transactionBox.get(id);

      if (transaction != null && transaction.attachmentPath != null) {
        final file = File(transaction.attachmentPath!);
        if (await file.exists()) {
          await file.delete();
          log('File lampiran ${transaction.attachmentPath!} berhasil dihapus.');
        }
      }

      await _transactionBox.delete(id);
    } catch (e, stack) {
      log('Error saat menghapus transaksi & file: $e');
      log(stack.toString());
      throw Exception('Gagal menghapus transaksi dan file lampiran.');
    }
  }

  @override
  List<TransactionModel> getAllTransactions() {
    var transactions = _transactionBox.values.toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  @override
  Box<TransactionModel> getTransactionBox() {
    return _transactionBox;
  }
}