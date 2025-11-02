import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:apkpribadi/core/constants.dart';
import 'package:apkpribadi/core/utils/formatters.dart';
import 'package:apkpribadi/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:open_filex/open_filex.dart';
import 'package:apkpribadi/presentation/screens/edit_transaction/edit_transaction_screen.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionDetailScreen({super.key, required this.transaction});

  bool _isImageFile(String path) {
    final extension = p.extension(path).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp'].contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    final color = transaction.type == TransactionType.income
        ? AppColors.income
        : AppColors.expense;
    final sign = transaction.type == TransactionType.income ? '+' : '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTransactionScreen(
                    transaction: transaction,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 0,
            color: color.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    '$sign ${Formatters.formatCurrency(transaction.amount)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      transaction.category,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    avatar: Icon(
                      transaction.type == TransactionType.income
                          ? Iconsax.arrow_down_2
                          : Iconsax.arrow_up_1,
                    ),
                    backgroundColor: color.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            icon: Iconsax.calendar_1,
            title: 'Tanggal',
            value: Formatters.formatDateTime(transaction.date),
          ),
          _buildDetailRow(
            context,
            icon: Iconsax.note,
            title: 'Catatan',
            value: transaction.notes ?? '-',
          ),
          const Divider(height: 32),
          Text(
            'Bukti Transaksi',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildAttachmentViewer(context),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context,
      {required IconData icon, required String title, required String value}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(
        value,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAttachmentViewer(BuildContext context) {
    if (transaction.attachmentPath == null) {
      return const Center(
        child: Text(
          'Tidak ada bukti transaksi.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    final file = File(transaction.attachmentPath!);

    if (!file.existsSync()) {
      return const Center(
        child: Text(
          'File tidak ditemukan (mungkin terhapus).',
          style: TextStyle(color: AppColors.expense),
        ),
      );
    }

    if (_isImageFile(transaction.attachmentPath!)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Text('Gagal memuat gambar.'));
          },
        ),
      );
    } else {
      return Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: ListTile(
          leading: const Icon(Iconsax.document_text),
          title: Text(p.basename(file.path)),
          subtitle: const Text('File dokumen'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () async {
            final result = await OpenFilex.open(file.path);
            if (result.type != ResultType.done) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal membuka file: ${result.message}'),
                  ),
                );
              }
            }
          },
        ),
      );
    }
  }
}