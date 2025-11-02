import 'package:flutter/material.dart';

const String kTransactionBox = 'transactions';

class AppColors {
  static const Color primary = Color(0xFF006A4E);
  static const Color primaryLight = Color(0xFF50977A);
  static const Color primaryDark = Color(0xFF004028);

  static const Color secondary = Color(0xFFF9A825);

  static const Color income = Color(0xFF2ECC71);
  static const Color expense = Color(0xFFE74C3C);

  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFF212121);

  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textDark = Color(0xFFE0E0E0);
}

const List<String> kIncomeCategories = [
  'Gaji',
  'Bonus',
  'Investasi',
  'Hadiah',
  'Lainnya'
];

const List<String> kExpenseCategories = [
  'Makanan',
  'Transportasi',
  'Tagihan',
  'Hiburan',
  'Belanja',
  'Kesehatan',
  'Pendidikan',
  'Lainnya'
];