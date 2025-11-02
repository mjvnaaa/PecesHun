import 'package:apkpribadi/core/constants.dart';
import 'package:apkpribadi/core/utils/formatters.dart';
import 'package:apkpribadi/data/models/transaction_model.dart';
import 'package:apkpribadi/presentation/screens/transaction_detail/transaction_detail_screen.dart';
import 'package:apkpribadi/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TransactionListTile extends ConsumerWidget {
  final TransactionModel transaction;
  const TransactionListTile({super.key, required this.transaction});

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Iconsax.shopping_bag;
      case 'transportasi':
        return Iconsax.car;
      case 'gaji':
        return Iconsax.wallet_money;
      case 'tagihan':
        return Iconsax.receipt_2_1;
      case 'belanja':
        return Iconsax.shop;
      case 'hiburan':
        return Iconsax.game;
      default:
        return Iconsax.category;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = transaction.type == TransactionType.income
        ? AppColors.income
        : AppColors.expense;
    final sign = transaction.type == TransactionType.income ? '+' : '-';

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.expense,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Iconsax.trash, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref
            .read(transactionListProvider.notifier)
            .deleteTransaction(transaction.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi dihapus')),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(_getCategoryIcon(transaction.category), color: color),
          ),
          title: Text(
            transaction.category,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            Formatters.formatDate(transaction.date),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign ${Formatters.formatCurrency(transaction.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 15,
                ),
              ),
              if (transaction.attachmentPath != null)
                const Icon(
                  Iconsax.attach_square,
                  size: 14,
                  color: Colors.grey,
                ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TransactionDetailScreen(transaction: transaction),
              ),
            );
          },
        ),
      ),
    );
  }
}