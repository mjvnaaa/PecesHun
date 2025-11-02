import 'package:apkpribadi/core/constants.dart';
import 'package:apkpribadi/presentation/charts/summary_pie_chart.dart';
import 'package:apkpribadi/presentation/screens/add_transaction/add_transaction_screen.dart';
import 'package:apkpribadi/presentation/widgets/expense_insights_card.dart';
import 'package:apkpribadi/presentation/widgets/metrics_card.dart';
import 'package:apkpribadi/presentation/widgets/transaction_list_tile.dart';
import 'package:apkpribadi/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dashboardMetricsProvider);
    final transactions = ref.watch(transactionListProvider);

    final totalIncome = metrics['income'] ?? 0.0;
    final totalExpense = metrics['expense'] ?? 0.0;
    final totalBalance = metrics['balance'] ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PecesHun'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 100.0),
        children: [
          MetricsCard(
            title: 'Saldo Saat Ini',
            amount: totalBalance,
            color: Theme.of(context).colorScheme.primary,
            icon: Iconsax.wallet_2,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: MetricsCard(
                      title: 'Total Pemasukan',
                      amount: totalIncome,
                      color: AppColors.income,
                      icon: Iconsax.arrow_down_2,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: MetricsCard(
                      title: 'Total Pengeluaran',
                      amount: totalExpense,
                      color: AppColors.expense,
                      icon: Iconsax.arrow_up_1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const ExpenseInsightsCard(),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
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
                    height: 220,
                    child: transactions.isEmpty
                        ? const Center(child: Text('Data transaksi kosong.'))
                        : const SummaryPieChart(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Transaksi Terakhir',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Belum ada transaksi.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
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
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Iconsax.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}