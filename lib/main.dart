// lib/main.dart
import 'dart:developer';
import 'package:apkpribadi/core/theme/app_theme.dart';
import 'package:apkpribadi/data/models/transaction_model.dart';
import 'package:apkpribadi/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 📦 Inisialisasi Hive di direktori aplikasi
    final appDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDir.path);

    // 🧩 Daftarkan Adapter Hive
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());

    // 🔓 Buka box transaksi (jika gagal, log error)
    await Hive.openBox<TransactionModel>('transactions');
    log('Hive box "transactions" berhasil dibuka.');

    // 🌏 Inisialisasi locale (pakai Indonesia)
    Intl.defaultLocale = 'id_ID';
    await initializeDateFormatting('id_ID', null);

    // 🚀 Jalankan aplikasi utama
    runApp(const ProviderScope(child: FinTrackApp()));
  } catch (e, stack) {
    log('❌ Gagal inisialisasi aplikasi: $e');
    log(stack.toString());
  }
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PecesHun',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Sesuai sistem pengguna
      home: const DashboardScreen(),
    );
  }
}