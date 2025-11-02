// lib/presentation/screens/dashboard/dashboard_screen.dart
import 'package:apkpribadi/core/constants.dart';
import 'package:apkpribadi/presentation/charts/summary_pie_chart.dart';
import 'package:apkpribadi/presentation/screens/add_transaction/add_transaction_screen.dart';
import 'package:apkpribadi/presentation/widgets/expense_insights_card.dart';
import 'package:apkpribadi/presentation/widgets/metrics_card.dart';
import 'package:apkpribadi/presentation/widgets/transaction_list_tile.dart';
import 'package:apkpribadi/providers/transaction_provider.dart';
import 'package:flutter/material.dart'; // <-- INI YANG DIPERBAIKI
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Pantau (watch) provider yang relevan
    final metrics = ref.watch(dashboardMetricsProvider);
    final transactions = ref.watch(transactionListProvider);

    // 2. Ambil data metrik (sudah dihitung oleh provider)
    final totalIncome = metrics['income'] ?? 0.0;
    final totalExpense = metrics['expense'] ?? 0.0;
    final totalBalance = metrics['balance'] ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FinTrack Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 80.0), // Padding untuk FAB
        children: [
          // Bagian Saldo Utama
          MetricsCard(
            title: 'Saldo Saat Ini',
            amount: totalBalance,
            color: Theme.of(context).colorScheme.primary,
            icon: Iconsax.wallet_2,
          ),
          const SizedBox(height: 12),

          // Grid Pemasukan & Pengeluaran
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.9, // Sesuaikan rasio agar pas
            children: [
              MetricsCard(
                title: 'Total Pemasukan',
                amount: totalIncome,
                color: AppColors.income,
                icon: Iconsax.arrow_down_2,
              ),
              MetricsCard(
                title: 'Total Pengeluaran',
                amount: totalExpense,
                color: AppColors.expense,
                icon: Iconsax.arrow_up_1,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Analisis Cerdas (dari widget Anda)
          const ExpenseInsightsCard(),

          const SizedBox(height: 20),

          // Grafik Pie Pengeluaran
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Pengeluaran',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200, // Beri tinggi tetap untuk chart
                    child: transactions.isEmpty
                        ? const Center(child: Text('Data transaksi kosong.'))
                        : const SummaryPieChart(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Daftar Transaksi Terakhir
          Text(
            'Transaksi Terakhir',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          if (transactions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Belum ada transaksi.',
                    style: TextStyle(fontStyle: FontStyle.italic)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return TransactionListTile(transaction: transactions[index]);
              },
            ),
        ],
      ),

      // Tombol Tambah Transaksi
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Iconsax.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}