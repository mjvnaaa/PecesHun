// lib/data/models/transaction_model.dart
import 'package:hive/hive.dart';

// Jalankan "flutter pub run build_runner build" di terminal untuk generate file ini
part 'transaction_model.g.dart';

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  income,
  
  @HiveField(1)
  expense,
}

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late double amount;

  @HiveField(2)
  late String category;

  @HiveField(3)
  late DateTime date;

  @HiveField(4)
  late String? notes;

  @HiveField(5)
  late TransactionType type;

  @HiveField(6)
  late String? attachmentPath; // Path ke file lokal

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    required this.type,
    this.attachmentPath,
  });
}