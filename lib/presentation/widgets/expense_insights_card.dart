// lib/presentation/widgets/expense_insights_card.dart
import 'package:apkpribadi/core/constants.dart'; // <-- Pastikan import ini
import 'package:apkpribadi/providers/analysis_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apkpribadi/core/utils/formatters.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ExpenseInsightsCard extends ConsumerWidget {
  const ExpenseInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(advancedAnalysisProvider);
    final theme = Theme.of(context);

    // Ambil data analisis
    final highestCategory = analysis['highestCategory']?.toString() ?? 'N/A';
    final avgExpense = analysis['averageExpensePerDay'] as double;
    final daysTracked = analysis['totalDaysTracked'] as int;
    final trend = analysis['trend']?.toString() ?? 'stabil';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 Analisis Pengeluaran',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: theme.dividerColor.withOpacity(0.5), height: 20),
            
            _buildInsightRow(
              context,
              icon: Iconsax.category,
              title: 'Kategori Terbesar',
              value: highestCategory,
            ),
            _buildInsightRow(
              context,
              icon: Iconsax.calculator,
              title: 'Rata-rata Harian',
              value: Formatters.formatCurrency(avgExpense),
            ),
            _buildInsightRow(
              context,
              icon: Iconsax.calendar_1,
              title: 'Periode Data',
              value: '$daysTracked hari',
            ),
            _buildInsightRow(
              context,
              icon: _getTrendIcon(trend),
              title: 'Tren Minggu Ini',
              value: trend.toUpperCase(),
              color: _getTrendColor(trend),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow(BuildContext context,
      {required IconData icon,
      required String title,
      required String value,
      Color? color}) {
    final theme = Theme.of(context);
    final defaultColor = theme.textTheme.bodyMedium?.color;
    final valueColor = color ?? defaultColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: defaultColor?.withOpacity(0.8)
                ),
              ),
            ],
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi helper untuk ikon dan warna tren
  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'naik':
        return Iconsax.trend_up;
      case 'turun':
        return Iconsax.trend_down;
      default:
        return Iconsax.arrow_right;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'naik':
        return AppColors.expense; // Merah
      case 'turun':
        return AppColors.income; // Hijau
      default:
        return AppColors.primary; // Netral
    }
  }
}