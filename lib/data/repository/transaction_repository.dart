// lib/data/repository/transaction_repository.dart
import 'dart:developer'; // <-- DIPERLUKAN
import 'dart:io'; // <-- DIPERLUKAN
import 'package:apkpribadi/core/constants.dart';
import 'package:apkpribadi/data/models/transaction_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Interface
abstract class TransactionRepository {
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<void> updateTransaction(TransactionModel transaction);
  List<TransactionModel> getAllTransactions();
  Box<TransactionModel> getTransactionBox();
}

// Implementasi
class TransactionRepositoryImpl implements TransactionRepository {
  final Box<TransactionModel> _transactionBox;

  TransactionRepositoryImpl()
      : _transactionBox = Hive.box<TransactionModel>(kTransactionBox);

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    // Menggunakan ID unik (dari model) sebagai key
    await _transactionBox.put(transaction.id, transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      // --- PERBAIKAN BUG ---
      // 1. Ambil data transaksi SEBELUM dihapus dari Hive
      final transaction = _transactionBox.get(id);

      // 2. Hapus file lampiran (gambar/pdf) terkait jika ada
      if (transaction != null && transaction.attachmentPath != null) {
        final file = File(transaction.attachmentPath!);
        
        // Cek apakah file-nya ada
        if (await file.exists()) {
          await file.delete(); // Hapus file dari memori HP
          log('File lampiran ${transaction.attachmentPath!} berhasil dihapus.');
        }
      }
      // --- AKHIR PERBAIKAN ---

      // 3. Hapus data dari Hive
      await _transactionBox.delete(id);

    } catch (e, stack) {
      log('Error saat menghapus transaksi & file: $e');
      log(stack.toString());
      // Melempar error lagi agar UI bisa tahu jika ada masalah
      throw Exception('Gagal menghapus transaksi dan file lampiran.');
    }
  }

  @override
  List<TransactionModel> getAllTransactions() {
    // Ambil semua data dan urutkan dari yang terbaru
    var transactions = _transactionBox.values.toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    // 'put' akan menimpa data jika key (ID) sudah ada
    await _transactionBox.put(transaction.id, transaction);
  }

  @override
  Box<TransactionModel> getTransactionBox() {
    return _transactionBox;
  }
}