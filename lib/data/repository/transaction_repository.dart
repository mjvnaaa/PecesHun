import 'dart:developer';
import 'dart:io';
import '../../core/constants.dart';
import 'package:apkpribadi/data/models/transaction_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class TransactionRepository {
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<void> deleteTransactionDataOnly(String id);
  Future<void> deleteAttachmentFile(TransactionModel transaction);
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
  Future<void> deleteAttachmentFile(TransactionModel transaction) async {
    if (transaction.attachmentPath != null) {
      final file = File(transaction.attachmentPath!);
      if (await file.exists()) {
        await file.delete();
        log('File lampiran ${transaction.attachmentPath!} berhasil dihapus.');
      }
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      final transaction = _transactionBox.get(id);

      if (transaction != null) {
        await deleteAttachmentFile(transaction);
      }

      await _transactionBox.delete(id);
    } catch (e, stack) {
      log('Error saat menghapus transaksi & file: $e');
      log(stack.toString());
      throw Exception('Gagal menghapus transaksi dan file lampiran.');
    }
  }

  @override
  Future<void> deleteTransactionDataOnly(String id) async {
    await _transactionBox.delete(id);
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